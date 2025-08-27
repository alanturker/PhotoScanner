//
//  GroupDetailViewModelTests.swift
//  PhotoScannerTests
//
//  Created by Turker Alan on 27.08.2025.
//

import XCTest
@testable import PhotoScanner

final class GroupDetailViewModelTests: XCTestCase {
    private var viewModel: GroupDetailViewModel!
    private var mockPhotoService: MockPhotoService!
    
    override func setUp() {
        super.setUp()
        mockPhotoService = MockPhotoService()
        viewModel = GroupDetailViewModel(photoService: mockPhotoService)
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        mockPhotoService = nil
    }
    
    func testInitialState() {
        XCTAssertTrue(viewModel.assets.isEmpty)
        XCTAssertFalse(viewModel.showImageDetail)
        XCTAssertEqual(viewModel.selectedIndex, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.groupItem)
    }
    
    func testConfigure() {
        let groupItem = GroupItem(type: .group(.a), count: 3, assetIds: ["1", "2", "3"])

        viewModel.configure(with: groupItem)
        
        XCTAssertEqual(viewModel.groupItem?.count, 3)
        XCTAssertEqual(viewModel.groupItem?.assetIds, ["1", "2", "3"])
    }
    
    func testSelectAssetValidIndex() {
        viewModel.assets = []
       
        viewModel.selectAsset(at: 0)
        
        XCTAssertEqual(viewModel.selectedIndex, 0)
        XCTAssertFalse(viewModel.showImageDetail)
    }
}
