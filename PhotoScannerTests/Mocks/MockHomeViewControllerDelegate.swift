//
//  MockHomeViewControllerDelegate.swift
//  PhotoScannerTests
//
//  Created by Turker Alan on 27.08.2025.
//

import Photos
import Foundation
@testable import PhotoScanner

final class MockHomeViewControllerDelegate: HomeViewControllerProtocol {
    var updateProgressCalled = false
    var updateGroupedAssetsCalled = false
    var updateScanButtonStateCalled = false
    var showScanCompletedCalled = false
    var updatePhotoAccessCalled = false
    var showErrorAlertCalled = false
    
    func updateProgress(_ progress: ScanProgress) {
        updateProgressCalled = true
    }
    
    func updateGroupedAssets(_ groupedAssets: GroupedAssets) {
        updateGroupedAssetsCalled = true
    }
    
    func updateScanButtonState(isScanning: Bool) {
        updateScanButtonStateCalled = true
    }
    
    func showScanCompleted() {
        showScanCompletedCalled = true
    }
    
    func updatePhotoAccess(_ hasAccess: Bool) {
        updatePhotoAccessCalled = true
    }
    
    func showAlert(title: String, message: String) {}
    
    func showConfirmationAlert(title: String, message: String, confirmAction: @escaping () -> Void) {}
    
    func showErrorAlert(error: Error) {
        showErrorAlertCalled = true
    }
}
