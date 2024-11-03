//
//  GameDetailViewModelTests.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 28/10/2024.
//

import XCTest
import SwiftUI
@testable import MyPinch

class GameDetailViewModelTests: XCTestCase {
    var mockCoverPhotoLoader = MockCoverPhotoLoader()
    var mockCoverPhotoService: MockCoverPhotoFetchService!
    var mockImageStore: MockImageDataStorage!
    var mockImageDownloadService: MockImageDownloadService!
    var mockGame: Game!

    override func setUp() {
        super.setUp()
        mockCoverPhotoService = mockCoverPhotoLoader.mockCoverPhotoService
        mockImageStore = mockCoverPhotoLoader.mockImageStorage
        mockImageDownloadService = mockCoverPhotoLoader.mockImageDownloadService
        mockGame = Game(id: 131913, name: "Maji Kyun! Renaissance", rating: 0.0, storyLine: "test storyline", summary: "A cross media collaboration project between Sunrise & Broccolli.", coverId: 267633, checksum: UUID(), coverPhotoModel: nil)
    }

    override func tearDown() {
        mockImageDownloadService = nil
        mockImageStore = nil
        mockCoverPhotoService = nil
        super.tearDown()
    }
    
    func testGameNameAndSummaryAndFallback() {
        let viewModel = GameDetailViewModel(game: mockGame, coverImageId: "267633", coverPhotoLoader: mockCoverPhotoLoader)
        XCTAssertEqual(viewModel.gameName, "Maji Kyun! Renaissance")
        XCTAssertEqual(viewModel.gameSummary, "A cross media collaboration project between Sunrise & Broccolli.")
        
        let mockGame1 = Game(id: 131913, name: nil, rating: 0.0, storyLine: "test storyline", summary: nil, coverId: 267633, checksum: UUID(), coverPhotoModel: nil)
        
        let viewModel1 = GameDetailViewModel(game: mockGame1, coverImageId: "267633", coverPhotoLoader: mockCoverPhotoLoader)
        XCTAssertEqual(viewModel1.gameName, "Unknown Name")
        XCTAssertEqual(viewModel1.gameSummary, "Unknown summary")

    }

    func testViewModelIsLoadingImageFromCache() async {
        let viewModel = GameDetailViewModel(game: mockGame, coverImageId: "267633", coverPhotoLoader: mockCoverPhotoLoader)
        mockImageStore.imageToReturn = UIImage()
        await viewModel.loadImage()
        XCTAssertNotNil(viewModel.coverImage)
    }
    
    func testViewModelIsLoadingFromCoverPhotoServiceWhenImageIdNotPresent() async {
        let viewModel = GameDetailViewModel(game: mockGame, coverImageId: nil, coverPhotoLoader: mockCoverPhotoLoader)
        mockImageStore.imageToReturn = nil
        mockCoverPhotoService.gameImageModelToReturn = GameImageModel(id: 267633, image_id: "267633")
        mockImageDownloadService.imageToReturn = UIImage()
        await viewModel.loadImage()
        XCTAssertNotNil(viewModel.coverImage)
    }
    
    func testViewModelIsLoadingFromCoverPhotoServiceButImageDownloadServiceFailsWithNoCache() async {
        let viewModel = GameDetailViewModel(game: mockGame, coverImageId: nil, coverPhotoLoader: mockCoverPhotoLoader)
        mockImageStore.imageToReturn = nil
        mockCoverPhotoService.gameImageModelToReturn = GameImageModel(id: 267633, image_id: "267633")
        mockImageDownloadService.imageToReturn = nil
        await viewModel.loadImage()
        XCTAssertEqual(viewModel.coverImage,  Image("dice"))
    }

}
