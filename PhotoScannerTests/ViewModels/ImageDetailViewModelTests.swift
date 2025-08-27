//
//  ImageDetailViewModelTests.swift
//  PhotoScannerTests
//
//  Created by Turker Alan on 27.08.2025.
//

import XCTest
import Photos
@testable import PhotoScanner

final class ImageDetailViewModelTests: XCTestCase {
    private var viewModel: ImageDetailViewModel!
    private var mockPhotoService: MockPhotoService!
    
    override func setUp() {
        super.setUp()
        mockPhotoService = MockPhotoService()
        viewModel = ImageDetailViewModel(photoService: mockPhotoService)
    }
    
    override func tearDown() {
        super.tearDown()
        mockPhotoService = nil
        viewModel = nil
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.currentIndex, 0)
        XCTAssertTrue(viewModel.assets.isEmpty)
        XCTAssertEqual(viewModel.totalCount, 0)
    }
    
    func testConfigureWithAssets() {
        let assets: [PHAsset] = []
        
        viewModel.configure(with: assets, initialIndex: 0)
        
        XCTAssertEqual(viewModel.assets.count, 0)
        XCTAssertEqual(viewModel.currentIndex, 0)
        XCTAssertEqual(viewModel.totalCount, 0)
    }
    
    func testMoveToNextWithMultipleAssets() {
        viewModel.currentIndex = 0
        viewModel.configure(with: [], initialIndex: 0)
        
        let initialIndex = viewModel.currentIndex
        
        if viewModel.canMoveToNext() {
            viewModel.moveToNext()
        }
        
        XCTAssertFalse(viewModel.canMoveToNext())
        XCTAssertEqual(viewModel.currentIndex, initialIndex)
    }
    
    func testCanMoveToNext() {
        viewModel.currentIndex = 0
        
        XCTAssertFalse(viewModel.canMoveToNext())
    }
    
    func testCanMoveToPrevious() {
        viewModel.currentIndex = 0
        
        XCTAssertFalse(viewModel.canMoveToPrevious())
    }
    
    func testProgressTextWithEmptyAssets() {
        viewModel.configure(with: [], initialIndex: 0)

        let progressText = viewModel.progressText()
  
        XCTAssertEqual(progressText, "0 of 0")
    }
    
    func testCurrentAssetWithEmptyAssets() {
        viewModel.configure(with: [], initialIndex: 0)
        
        let currentAsset = viewModel.currentAsset()
        
        XCTAssertNil(currentAsset)
    }
}
