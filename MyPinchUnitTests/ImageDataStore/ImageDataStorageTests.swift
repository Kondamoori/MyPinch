//
//  ImageDataStorageTests.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 27/10/2024.
//

import XCTest
@testable import MyPinch

class ImageDataCacheManagerTests: XCTestCase {
    
    func testInMemoryStorage_savesAndRetrievesImage() {
        let manager = ImageDataCacheManager(storageType: .inMemory)
        let testImage = UIImage(named: "testImage")!
        
        manager.saveImage(for: "testKey", with: testImage)
        let retrievedImage = manager.getImage(for: "testKey")
        
        XCTAssertNotNil(retrievedImage)
        XCTAssertEqual(retrievedImage, testImage)
    }
    
    func testPersistentStorage_savesAndRetrievesImage() {
        let manager = ImageDataCacheManager(storageType: .persistent)
        let testImage = UIImage(named: "testImage")!
        manager.saveImage(for: "testKey", with: testImage)
        let retrievedImage = manager.getImage(for: "testKey")
        
        XCTAssertNotNil(retrievedImage)
    }
    
}
