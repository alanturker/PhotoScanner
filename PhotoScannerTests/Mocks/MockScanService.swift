//
//  MockScanService.swift
//  PhotoScannerTests
//
//  Created by Turker Alan on 27.08.2025.
//

import Foundation
@testable import PhotoScanner

final class MockScanService: ScanServiceProtocol {
    var startScanningCalled = false
    var stopScanningCalled = false
    var clearDataCalled = false
    var loadSavedDataCalled = false
    
    var shouldSucceedClearData = true
    var mockScanProgress: ScanProgress?
    var mockGroupedAssets: GroupedAssets?
    
    func startScanning() async {
        startScanningCalled = true
    }
    
    func stopScanning() {
        stopScanningCalled = true
    }
    
    func clearData() async throws {
        clearDataCalled = true
        if !shouldSucceedClearData {
            throw TestError.mockError
        }
    }
    
    func loadSavedData() async throws -> (ScanProgress?, GroupedAssets?) {
        loadSavedDataCalled = true
        return (mockScanProgress, mockGroupedAssets)
    }
    
    func getScanProgress() async -> ScanProgress? {
        return mockScanProgress
    }
    
    func getGroupedAssets() async -> GroupedAssets? {
        return mockGroupedAssets
    }
}
