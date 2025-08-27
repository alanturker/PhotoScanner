//
//  GroupDetailViewModel.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Photos
import UIKit

final class GroupDetailViewModel: GroupDetailViewModelProtocol {
    
    @Published var assets: [PHAsset] = []
    @Published var showImageDetail: Bool = false
    @Published var selectedIndex: Int = 0
    @Published var isLoading: Bool = false
    
    private(set) var groupItem: GroupItem?
    
    private let photoService: PhotoServiceProtocol
    
    init(photoService: PhotoServiceProtocol = PhotoService()) {
        self.photoService = photoService
    }
    
    func configure(with item: GroupItem) {
        self.groupItem = item
    }
    
    func loadAssets() {
        guard let groupItem = groupItem else { return }
        
        isLoading = true
        
        let assetIds = groupItem.assetIds
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: assetIds, options: nil)
        
        assets.removeAll()
        fetchResult.enumerateObjects { asset, _, _ in
            self.assets.append(asset)
        }
        
        isLoading = false
    }
    
    func selectAsset(at index: Int) {
        guard index < assets.count else { return }
        selectedIndex = index
        showImageDetail = true
    }
    
    func loadThumbnail(for asset: PHAsset, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        Task {
            let image = await photoService.requestThumbnail(for: asset, size: size)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
