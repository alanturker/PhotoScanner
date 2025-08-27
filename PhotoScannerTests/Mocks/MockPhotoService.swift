//
//  MockPhotoService.swift
//  PhotoScannerTests
//
//  Created by Turker Alan on 27.08.2025.
//

import Photos
import UIKit
@testable import PhotoScanner

final class MockPhotoService: PhotoServiceProtocol {
    var shouldGrantAccess = true
    var requestAccessCalled = false
    
    func requestAccess() async -> Bool {
        requestAccessCalled = true
        return shouldGrantAccess
    }
    
    func fetchAllAssets() async -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: .image, options: nil)
    }
    
    func requestThumbnail(for asset: PHAsset, size: CGSize) async -> UIImage? {
        return UIImage()
    }
    
    func requestFullImage(for asset: PHAsset) async -> UIImage? {
        return UIImage()
    }
}
