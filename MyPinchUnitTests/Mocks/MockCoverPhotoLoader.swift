//
//  MockCoverPhotoLoader.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 01/11/2024.
//

import Foundation
@testable import MyPinch

struct MockCoverPhotoLoader: CoverPhotoLoaderProtocol {
    var coverPhotoDataDownloadService: any MyPinch.CoverPhotoServiceProtocol
    
    var imageDownloadService: any MyPinch.ImageDownloadServiceProtocol
    
    var imageStorage: any MyPinch.ImageStorage
    
    var mockCoverPhotoService: MockCoverPhotoFetchService? {
        return coverPhotoDataDownloadService as? MockCoverPhotoFetchService
    }
    
    var mockImageDownloadService: MockImageDownloadService? {
        return imageDownloadService as? MockImageDownloadService
    }
    
    var mockImageStorage: MockImageDataStorage? {
        return imageStorage as? MockImageDataStorage
    }

    
    init(coverPhotoDataDownloadService: any MyPinch.CoverPhotoServiceProtocol = MockCoverPhotoFetchService(), imageDownloadService: any MyPinch.ImageDownloadServiceProtocol = MockImageDownloadService(), imageStorage: any MyPinch.ImageStorage = MockImageDataStorage()) {
        self.coverPhotoDataDownloadService = coverPhotoDataDownloadService
        self.imageDownloadService = imageDownloadService
        self.imageStorage = imageStorage
    }
}
