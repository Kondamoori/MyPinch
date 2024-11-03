//
//  MockImageDataStorage.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 29/10/2024.
//

import UIKit
@testable import MyPinch

class MockImageDataStorage: ImageStorage {
    private var imageCache: [String: UIImage] = [:]

    var imageToReturn: UIImage?
    
    // Mock returning an image from cache
    func getImage(for key: String) -> UIImage? {
        return imageToReturn
    }

    // Mock saving an image to cache
    func saveImage(for key: String, with image: UIImage) {
        imageToReturn = image
    }
    
    // Optional: Clear the cache for testing purposes
    func clearCache() {
        imageToReturn = nil
    }
}
