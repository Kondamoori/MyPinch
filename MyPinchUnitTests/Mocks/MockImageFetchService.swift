//
//  MockImageFetchService.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 28/10/2024.
//

import UIKit
@testable import MyPinch

class MockCoverPhotoFetchService: CoverPhotoServiceProtocol {
    
    var gameImageModelToReturn: GameImageModel?
    var shouldFail = false
    var requestCounter = 0

    func fetchCoverPhotosData(endPoint: MyPinch.ImagesEndPoint) async throws -> [MyPinch.GameImageModel] {
        if shouldFail {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image fetch error"])
        }
        
        requestCounter += 1
        if let gameImageModelToReturn {
            return [gameImageModelToReturn]
        }
        
        return []
    }
}

class MockImageDownloadService: ImageDownloadServiceProtocol {
    
    var imageToReturn: UIImage?
    var shouldFail: Bool = false
    var lastUrlString: String?
    var requestCounter = 0
        
    func downloadImage(url: URL) async throws -> UIImage? {
        requestCounter += 1
        lastUrlString = url.absoluteString
        return imageToReturn
    }
}
