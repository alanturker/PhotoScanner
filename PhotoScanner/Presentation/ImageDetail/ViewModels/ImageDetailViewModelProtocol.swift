//
//  ImageDetailViewModelProtocol.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Photos
import UIKit

protocol ImageDetailViewModelProtocol: ObservableObject {
    var currentIndex: Int { get set }
    var totalCount: Int { get }
    var assets: [PHAsset] { get }
    
    func configure(with assets: [PHAsset], initialIndex: Int)
    
    func moveToNext()
    func moveToPrevious()
    func canMoveToNext() -> Bool
    func canMoveToPrevious() -> Bool
    
    func currentAsset() -> PHAsset?
    func progressText() -> String
    
    func loadFullImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void)
}
