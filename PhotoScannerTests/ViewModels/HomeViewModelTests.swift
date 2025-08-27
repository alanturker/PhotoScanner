//
//  HomeViewModelTests.swift
//  PhotoScannerTests
//
//  Created by Turker Alan on 27.08.2025.
//

import XCTest
@testable import PhotoScanner

final class HomeViewModelTests: XCTestCase {
    private var viewModel: HomeViewModel!
    private var mockScanService: MockScanService!
    private var mockPhotoService: MockPhotoService!
    private var mockDelegate: MockHomeViewControllerDelegate!
    
    override func setUp() {
        super.setUp()
        mockScanService = MockScanService()
        mockPhotoService = MockPhotoService()
        mockDelegate = MockHomeViewControllerDelegate()
        
        viewModel = HomeViewModel(
            scanService: mockScanService,
            photoService: mockPhotoService
        )
        viewModel.delegate = mockDelegate
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel.stopScanning() 
        viewModel.delegate = nil
        viewModel = nil
        mockScanService = nil
        mockPhotoService = nil
        mockDelegate = nil
    }
    
    func testInitialState() {
        XCTAssertNil(viewModel.scanProgress)
        XCTAssertTrue(viewModel.groupItems.isEmpty)
        XCTAssertFalse(viewModel.isScanning)
        XCTAssertFalse(viewModel.hasPhotoAccess)
    }
    
    func testStartScanningWithPermission() async {
        mockPhotoService.shouldGrantAccess = true
        
        viewModel.startScanning()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.isScanning)
        XCTAssertTrue(viewModel.hasPhotoAccess)
        XCTAssertTrue(mockScanService.startScanningCalled)
    }
    
    func testStartScanningWithoutPermission() async {
        mockPhotoService.shouldGrantAccess = false
        
        viewModel.startScanning()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(mockPhotoService.requestAccessCalled)
        XCTAssertFalse(viewModel.isScanning)
        XCTAssertFalse(viewModel.hasPhotoAccess)
        XCTAssertTrue(mockDelegate.updatePhotoAccessCalled)
    }
    
    func testStopScanning() {
        viewModel.isScanning = true
        
        viewModel.stopScanning()
        
        XCTAssertFalse(viewModel.isScanning)
        XCTAssertTrue(mockScanService.stopScanningCalled)
    }
    
    func testNumberOfItems() {
        let item1 = GroupItem(type: .group(.a), count: 5, assetIds: ["1", "2", "3", "4", "5"])
        let item2 = GroupItem(type: .other, count: 3, assetIds: ["6", "7", "8"])
        viewModel.groupItems = [item1, item2]
        
        XCTAssertEqual(viewModel.numberOfItems(), 2)
    }
    
    func testItemAtIndex() {
        let item = GroupItem(type: .group(.a), count: 5, assetIds: ["1", "2", "3", "4", "5"])
        viewModel.groupItems = [item]
        
        XCTAssertNotNil(viewModel.item(at: 0))
        XCTAssertNil(viewModel.item(at: 1))
        XCTAssertNil(viewModel.item(at: -1))
    }
}
