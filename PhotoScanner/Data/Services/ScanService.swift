//
//  ScanService.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Photos
import Foundation

protocol ScanServiceProtocol {
    func startScanning() async
    func stopScanning()
    func clearData() async throws
    func loadSavedData() async throws -> (ScanProgress?, GroupedAssets?)
    func getScanProgress() async -> ScanProgress?
    func getGroupedAssets() async -> GroupedAssets?
}

final class ScanService: ScanServiceProtocol {
    private let photoService: PhotoServiceProtocol
    private let storageService: StorageServiceProtocol
    
    private var currentTask: Task<Void, Never>?
    private var isScanning = false
    private var shouldStop = false
    
    private let progressFileName = "scan_progress.json"
    private let groupedAssetsFileName = "grouped_assets.json"
    private let batchSize = 10
    
    init(photoService: PhotoServiceProtocol = PhotoService(),
         storageService: StorageServiceProtocol = StorageService()) {
        self.photoService = photoService
        self.storageService = storageService
    }
    
    func startScanning() async {
        guard !isScanning else { return }
        
        isScanning = true
        shouldStop = false
        
        currentTask = Task {
            await performScan()
        }
    }
    
    func stopScanning() {
        shouldStop = true
        currentTask?.cancel()
        isScanning = false
    }
    
    func clearData() async throws {
        stopScanning()
        
        try await storageService.delete(fileName: progressFileName)
        try await storageService.delete(fileName: groupedAssetsFileName)
    }
    
    func loadSavedData() async throws -> (ScanProgress?, GroupedAssets?) {
        let progress = try await storageService.load(ScanProgress.self, from: progressFileName)
        let groupedAssets = try await storageService.load(GroupedAssets.self, from: groupedAssetsFileName)
        
        return (progress, groupedAssets)
    }
    
    func getScanProgress() async -> ScanProgress? {
        return try? await storageService.load(ScanProgress.self, from: progressFileName)
    }
    
    func getGroupedAssets() async -> GroupedAssets? {
        return try? await storageService.load(GroupedAssets.self, from: groupedAssetsFileName)
    }
    
    private func performScan() async {
        do {
            let allAssets = await photoService.fetchAllAssets()
            let totalCount = allAssets.count
            
            let existingProgress = try? await storageService.load(ScanProgress.self, from: progressFileName)
            let existingGroupedAssets = try? await storageService.load(GroupedAssets.self, from: groupedAssetsFileName)
            
            var processedCount = existingProgress?.processedAssets ?? 0
            var processedAssetIds = existingProgress?.processedAssetIds ?? Set<String>()
            var groupedAssets = existingGroupedAssets ?? GroupedAssets()
            
            for index in 0..<totalCount {
                if shouldStop || Task.isCancelled {
                    break
                }
                
                let asset = allAssets.object(at: index)
                
                if processedAssetIds.contains(asset.localIdentifier) {
                    continue
                }
                
                let hash = asset.reliableHash()
                let group = PhotoGroup.group(for: hash)
                
                groupedAssets.addAsset(asset.localIdentifier, to: group)
                processedAssetIds.insert(asset.localIdentifier)
                processedCount += 1
                
                let progress = ScanProgress(
                    totalAssets: totalCount,
                    processedAssets: processedCount,
                    processedAssetIds: processedAssetIds
                )
                
                if processedCount % batchSize == 0 || processedCount == totalCount {
                    try? await storageService.save(progress, to: progressFileName)
                    try? await storageService.save(groupedAssets, to: groupedAssetsFileName)
                }
            }
        }
        
        isScanning = false
    }
}
