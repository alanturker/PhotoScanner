//
//  HomeViewModel.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Foundation

final class HomeViewModel: HomeViewModelProtocol {
    
    var scanProgress: ScanProgress?
    var groupItems: [GroupItem] = []
    var isScanning: Bool = false
    var hasPhotoAccess: Bool = false
    
    private let scanService: ScanServiceProtocol
    private let photoService: PhotoServiceProtocol
    
    private var groupedAssets = GroupedAssets()
    private var scanTask: Task<Void, Never>?
    
    weak var delegate: HomeViewControllerProtocol?

    init(scanService: ScanServiceProtocol = ScanService(),
         photoService: PhotoServiceProtocol = PhotoService()) {
        self.scanService = scanService
        self.photoService = photoService
    }
    
    func viewDidLoad() {
        Task {
            await requestPhotoAccess()
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await loadSavedData()
        }
    }
    
    func startScanning() {
        guard !isScanning else { return }
        
        scanTask = Task {
            let accessGranted = await photoService.requestAccess()
            
            await MainActor.run {
                if accessGranted {
                    self.hasPhotoAccess = true
                    self.isScanning = true
                    self.delegate?.updateScanButtonState(isScanning: true)
                    self.delegate?.updatePhotoAccess(true)
                } else {
                    self.hasPhotoAccess = false
                    self.isScanning = false
                    self.delegate?.updatePhotoAccess(false)
                    return
                }
            }
            if accessGranted {
                await scanService.startScanning()
                await monitorScanProgress()
            }
        }
    }
    
    func stopScanning() {
        scanService.stopScanning()
        scanTask?.cancel()
        isScanning = false
        delegate?.updateScanButtonState(isScanning: false)
    }
    
    func clearData() {
        Task {
            do {
                try await scanService.clearData()
                await MainActor.run {
                    self.scanProgress = nil
                    self.groupItems = []
                    self.groupedAssets = GroupedAssets()
                    
                    let emptyProgress = ScanProgress(totalAssets: 0, processedAssets: 0, processedAssetIds: [])
                    self.delegate?.updateProgress(emptyProgress)
                    self.delegate?.updateGroupedAssets(self.groupedAssets)
                }
            } catch {
                print("Failed to clear data: \(error)")
                await MainActor.run {
                    self.delegate?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    func requestPhotoAccess() async {
        let access = await photoService.requestAccess()
        await MainActor.run {
            self.hasPhotoAccess = access
            self.delegate?.updatePhotoAccess(access)
        }
    }
    
    func numberOfItems() -> Int {
        return groupItems.count
    }
    
    func item(at index: Int) -> GroupItem? {
        return groupItems[safe: index]
    }
    
    private func loadSavedData() async {
        do {
            let (progress, groupedAssets) = try await scanService.loadSavedData()
            
            await MainActor.run {
                if let progress = progress {
                    self.scanProgress = progress
                    self.delegate?.updateProgress(progress)
                    self.delegate?.updateScanButtonState(isScanning: isScanning)
                }
                
                if let groupedAssets = groupedAssets {
                    self.updateGroupItems(from: groupedAssets)
                }
            }
        } catch {
            print("Failed to load saved data: \(error)")
        }
    }
    
    private func monitorScanProgress() async {
        while isScanning {
            if let currentProgress = await scanService.getScanProgress() {
                await MainActor.run {
                    self.scanProgress = currentProgress
                    self.delegate?.updateProgress(currentProgress)
                    
                    if currentProgress.isComplete {
                        self.isScanning = false
                        self.delegate?.updateScanButtonState(isScanning: false)
                        self.delegate?.showScanCompleted()
                    }
                }
            }
            
            if let currentGroupedAssets = await scanService.getGroupedAssets() {
                await MainActor.run {
                    self.updateGroupItems(from: currentGroupedAssets)
                }
            }
        
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 0.5 seconds
        }
    }
    
    @MainActor
    private func updateGroupItems(from groupedAssets: GroupedAssets) {
        self.groupedAssets = groupedAssets
        self.groupItems = groupedAssets.getAllGroupItems()
        delegate?.updateGroupedAssets(groupedAssets)
    }
}
