//
//  ImageDetailViewModel.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Photos
import UIKit

final class ImageDetailViewModel: ImageDetailViewModelProtocol {
    
    @Published var currentIndex: Int = 0
    
    private(set) var assets: [PHAsset] = []
    
    var totalCount: Int {
        return assets.count
    }
    
    private let photoService: PhotoServiceProtocol
    
    init(photoService: PhotoServiceProtocol = PhotoService()) {
        self.photoService = photoService
    }
    
    
    
    func configure(with assets: [PHAsset], initialIndex: Int) {
        self.assets = assets
        self.currentIndex = initialIndex
    }
    
    func moveToNext() {
        guard canMoveToNext() else { return }
        currentIndex += 1
    }
    
    func moveToPrevious() {
        guard canMoveToPrevious() else { return }
        currentIndex -= 1
    }
    
    func canMoveToNext() -> Bool {
        return currentIndex < assets.count - 1
    }
    
    func canMoveToPrevious() -> Bool {
        return currentIndex > 0
    }
    
    func currentAsset() -> PHAsset? {
        guard currentIndex < assets.count else { return nil }
        return assets[currentIndex]
    }
    
    func progressText() -> String {
        guard !assets.isEmpty else { return "0 of 0" }
        return "\(currentIndex + 1) of \(totalCount)"
    }
    
    func loadFullImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        Task {
            let image = await photoService.requestFullImage(for: asset)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
