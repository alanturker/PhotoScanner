//
//  HomeViewModelProtocol.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import Foundation

protocol HomeViewModelProtocol: ObservableObject {
    var delegate: HomeViewControllerProtocol? { get set }

    var scanProgress: ScanProgress? { get }
    var groupItems: [GroupItem] { get }
    var isScanning: Bool { get }
    var hasPhotoAccess: Bool { get }
    
    func viewDidLoad()
    func startScanning()
    func stopScanning()
    func clearData()
    func requestPhotoAccess() async
    
    func numberOfItems() -> Int
    func item(at index: Int) -> GroupItem?
}
