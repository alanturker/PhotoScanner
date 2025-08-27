//
//  GroupDetailViewModelProtocol.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Photos
import UIKit

protocol GroupDetailViewModelProtocol: ObservableObject {
    var assets: [PHAsset] { get }
    var showImageDetail: Bool { get set }
    var selectedIndex: Int { get set }
    var isLoading: Bool { get }
    var groupItem: GroupItem? { get }

    func configure(with item: GroupItem)
    func loadAssets()
    func selectAsset(at index: Int)
    func loadThumbnail(for asset: PHAsset, size: CGSize, completion: @escaping (UIImage?) -> Void)
}
