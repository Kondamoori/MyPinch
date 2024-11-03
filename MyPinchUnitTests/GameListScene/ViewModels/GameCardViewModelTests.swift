//
//  GameCardViewModelTests.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 28/10/2024.
//

import XCTest
import UIKit
@testable import MyPinch

@MainActor
final class GameCardViewModelTests: XCTestCase {
    
    private var viewModel: GameCardViewModel!
    private var coverPhotoLoader = MockCoverPhotoLoader()
    private var mockCoverPhotoService: MockCoverPhotoFetchService!
    private var mockImageDownloadService: MockImageDownloadService!
    private var mockImageDataStore: MockImageDataStorage!
    private let mockGameImageModel = GameImageModel(id: 267633, image_id: "jljwou2o702523")
    private let mockGame = Game(id: 131913, name: "Maji Kyun! Renaissance", rating: 0.0, storyLine: "In a world where art becomes magic", summary: "A cross media collaboration project between Sunrise & Broccolli.", coverId: 267633, checksum: UUID(), coverPhotoModel: GameImageModel(id: 267633, image_id: "jljwou2o702523"))

   
    private lazy var mockRepository: CoreDataRepository<Game> = {
        let context = CoreDataStackTests.makeInMemoryContext()
        return CoreDataRepository(context: context)
    }()

    override func setUp() {
        super.setUp()
        mockCoverPhotoService = coverPhotoLoader.mockCoverPhotoService
        mockImageDownloadService = coverPhotoLoader.mockImageDownloadService
        mockImageDataStore = coverPhotoLoader.mockImageStorage
        viewModel = GameCardViewModel(game: mockGame, persistenceStore: mockRepository, coverPhotoLoader: coverPhotoLoader)
    }

    override func tearDown() {
        viewModel = nil
        mockImageDataStore = nil
        mockImageDownloadService = nil
        mockCoverPhotoService = nil
        super.tearDown()
    }
    
    // To test if cover image id is present for already loaded cell, should not request backend.
    func testLoadingInMemoryCoverIdIfExist() async {
        let viewModel = GameCardViewModel(game: mockGame, persistenceStore: mockRepository, coverPhotoLoader: coverPhotoLoader)

        mockCoverPhotoService.gameImageModelToReturn = mockGameImageModel
        mockImageDownloadService.imageToReturn = UIImage()
        await viewModel.loadImage()
        
        XCTAssertEqual(viewModel.state, GameCardViewModel.ImageState.loaded)
        XCTAssertEqual(mockCoverPhotoService.requestCounter, 1)
        
        await viewModel.loadImage()
        XCTAssertEqual(viewModel.state, GameCardViewModel.ImageState.loaded)
        XCTAssertEqual(mockCoverPhotoService.requestCounter, 1)
    }
    
    // To test if cover image id is present for already loaded cell, should not request backend.
    
    func testLoadingImageFailureCase() async {
        XCTAssertEqual(viewModel.state, .loading)

        mockCoverPhotoService.shouldFail = true
        await viewModel.loadImage()
        
        XCTAssertEqual(viewModel.state, .failed)
    }
    
    func testImageDownloadCaseHappyFlow() async {
        XCTAssertEqual(viewModel.state, .loading)

        mockCoverPhotoService.gameImageModelToReturn = mockGameImageModel
        mockImageDownloadService.imageToReturn = UIImage()
        await viewModel.loadImage()
        
        XCTAssertEqual(viewModel.state, .loaded)
        
        XCTAssertEqual(mockImageDownloadService.lastUrlString, ImageURLBuilder.buildImageURL(imageID: mockGameImageModel.image_id ?? "", size: .cover_image_big)?.absoluteString)
        XCTAssertNotNil(mockImageDataStore.getImage(for: mockGameImageModel.image_id ?? ""))
        
        let persistedData = try? await mockRepository.fetchAll()
        
        XCTAssertEqual(persistedData?.count, 1)
        XCTAssertEqual(persistedData?.first?.coverImageModel?.image_id, mockGameImageModel.image_id)
    }
    
    func testGettingImageFromLocalImageCacheWhenImageAlreadyExist() async {
        
        // Load happy flow to have image data on data repository
        mockCoverPhotoService.gameImageModelToReturn = mockGameImageModel
        mockImageDownloadService.imageToReturn = UIImage()
        await viewModel.loadImage()
        
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(mockImageDownloadService.requestCounter, 1)

        // Now Reloading the image but it should not go to download service, we already have it on cache.
        await viewModel.loadImage()
        XCTAssertEqual(mockImageDownloadService.requestCounter, 1)
        
        // Now delete the image from cache, it should go to service.
        mockImageDataStore.clearCache()
        await viewModel.loadImage()
        XCTAssertEqual(mockImageDownloadService.requestCounter, 2)
    }
    
    func testCoverPhotoServiceFailureWithPersistedCoverPhotoData() async {
        try? await mockRepository.save(model: mockGame)

        mockCoverPhotoService.shouldFail = true
        mockImageDownloadService.imageToReturn = UIImage()
        await viewModel.loadImage()
        
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(mockImageDownloadService.requestCounter, 1)
    }
    
}
