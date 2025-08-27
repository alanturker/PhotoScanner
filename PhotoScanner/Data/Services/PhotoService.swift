//
//  PhotoService.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Photos
import UIKit

protocol PhotoServiceProtocol {
    func requestAccess() async -> Bool
    func fetchAllAssets() async -> PHFetchResult<PHAsset>
    func requestThumbnail(for asset: PHAsset, size: CGSize) async -> UIImage?
    func requestFullImage(for asset: PHAsset) async -> UIImage?
}

final class PhotoService: PhotoServiceProtocol {
    
    func requestAccess() async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                continuation.resume(returning: status == .authorized || status == .limited)
            }
        }
    }
    
    func fetchAllAssets() async -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
    
    func requestThumbnail(for asset: PHAsset, size: CGSize) async -> UIImage? {
            await withCheckedContinuation { continuation in
                let manager = PHImageManager.default()
                let options = PHImageRequestOptions()
                
                options.deliveryMode = .opportunistic
                options.resizeMode = .fast
                options.isSynchronous = false
                options.isNetworkAccessAllowed = true
                options.version = .current
                
                var hasResumed = false
                
                manager.requestImage(
                    for: asset,
                    targetSize: size,
                    contentMode: .aspectFill,
                    options: options
                ) { result, info in
                    guard !hasResumed else { return }
                    
                    if let info = info,
                       let cancelled = info[PHImageCancelledKey] as? Bool,
                       cancelled {
                        hasResumed = true
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    if let info = info,
                       let error = info[PHImageErrorKey] as? Error {
                        print("Thumbnail error for asset \(asset.localIdentifier): \(error)")
                        hasResumed = true
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    if let info = info,
                       let isDegraded = info[PHImageResultIsDegradedKey] as? Bool,
                       isDegraded {
                        return
                    }
                    
                    hasResumed = true
                    continuation.resume(returning: result)
                }
            }
        }
        
        func requestFullImage(for asset: PHAsset) async -> UIImage? {
            await withCheckedContinuation { continuation in
                let manager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                options.isSynchronous = false
                options.version = .current
                
                var hasResumed = false
                
                manager.requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFit,
                    options: options
                ) { result, info in
                    guard !hasResumed else { return }
                    
                    if let info = info,
                       let cancelled = info[PHImageCancelledKey] as? Bool,
                       cancelled {
                        hasResumed = true
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    if let info = info,
                       let error = info[PHImageErrorKey] as? Error {
                        print("Full image error for asset \(asset.localIdentifier): \(error)")
                        hasResumed = true
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    if let info = info,
                       let isDegraded = info[PHImageResultIsDegradedKey] as? Bool,
                       isDegraded {
                        return
                    }
                    
                    hasResumed = true
                    continuation.resume(returning: result)
                }
            }
        }
}
