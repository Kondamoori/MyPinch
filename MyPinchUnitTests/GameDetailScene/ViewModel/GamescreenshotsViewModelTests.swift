//
//  GamescreenshotsViewModelTests.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 01/11/2024.
//

import Foundation
import XCTest
@testable import MyPinch

@MainActor
final class GamescreenshotsViewModelTests: XCTestCase {
    
    private var viewModel: GameScreenshotsViewModel!
    private var coverPhotoLoader = MockCoverPhotoLoader()
    private var mockCoverPhotoService: MockCoverPhotoFetchService!
    private var mockImageDownloadService: MockImageDownloadService!
    private var mockImageStore: MockImageDataStorage!
    private let mockGameImageModel = GameImageModel(id: 267633, image_id: "jljwou2o702523")
    private let mockGame = Game(id: 131913, name: "Maji Kyun! Renaissance", rating: 0.0, storyLine: "In a world where art becomes magic", summary: "A cross media collaboration project between Sunrise & Broccolli.", coverId: 267633, checksum: UUID(), screenshots: [GameImageModel(id: 267633, image_id: "jljwou2o702523")], coverPhotoModel: nil)
    
    
    private lazy var mockRepository: CoreDataRepository<Game> = {
        let context = CoreDataStackTests.makeInMemoryContext()
        return CoreDataRepository(context: context)
    }()
    
    override func setUp() {
        super.setUp()
        mockCoverPhotoService = coverPhotoLoader.mockCoverPhotoService
        mockImageDownloadService = coverPhotoLoader.mockImageDownloadService
        mockImageStore = coverPhotoLoader.mockImageStorage
    }
    
    override func tearDown() {
        viewModel = nil
        mockImageStore = nil
        mockImageDownloadService = nil
        mockCoverPhotoService = nil
        super.tearDown()
    }
    
    func testLoadingScreenshotIdsFromBackendAndLoadingImagesFromRemote() async {
        viewModel = GameScreenshotsViewModel(game: mockGame, coverPhotoLoader: coverPhotoLoader, repository: mockRepository)
        
        XCTAssertEqual(viewModel.screenshots.count, 0)
        
        mockCoverPhotoService.gameImageModelToReturn = mockGameImageModel
        mockImageDownloadService.imageToReturn = UIImage()
        await viewModel.fetchScreenshots()
        
        XCTAssertEqual(viewModel.screenshots.count, 1)
        XCTAssertEqual(viewModel.screenshots.first?.state, .loading)
        
        if let screenshot = viewModel.screenshots.first {
            await viewModel.loadScreenshot(for: screenshot)
        }
        
        guard let screenshot1 = viewModel.screenshots.first else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(screenshot1.state, .loaded)
        XCTAssertEqual(screenshot1.image, mockImageDownloadService.imageToReturn)
    }
    
    func testLoadingScreenshotIdsFromBackendButImageLoadingIsFromCacheIfExist() async {
        viewModel = GameScreenshotsViewModel(game: mockGame, coverPhotoLoader: coverPhotoLoader, repository: mockRepository)
        
        XCTAssertEqual(viewModel.screenshots.count, 0)
        
        mockCoverPhotoService.gameImageModelToReturn = mockGameImageModel
        mockImageStore.imageToReturn = UIImage()
        
        await viewModel.fetchScreenshots()
        
        XCTAssertEqual(viewModel.screenshots.count, 1)
        XCTAssertEqual(viewModel.screenshots.first?.state, .loading)
        
        if let screenshot = viewModel.screenshots.first {
            await viewModel.loadScreenshot(for: screenshot)
        }
        
        guard let screenshot1 = viewModel.screenshots.first else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(screenshot1.state, .loaded)
        XCTAssertEqual(screenshot1.image, mockImageStore.imageToReturn)
    }
    
    func testLoadingScreenshotsFromOfflineDataIfBackendFailsToRespond() async {
        viewModel = GameScreenshotsViewModel(game: mockGame, coverPhotoLoader: coverPhotoLoader, repository: mockRepository)
        
        XCTAssertEqual(viewModel.screenshots.count, 0)
        
        mockCoverPhotoService.shouldFail = true
        mockImageStore.imageToReturn = UIImage()
        
        // Save the game first in database
        do {
            try await mockRepository.save(model: mockGame)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        await viewModel.fetchScreenshots()
        
        XCTAssertEqual(viewModel.screenshots.count, 1)
        XCTAssertEqual(viewModel.screenshots.first?.state, .loading)
        
        if let screenshot = viewModel.screenshots.first {
            await viewModel.loadScreenshot(for: screenshot)
        }
        
        guard let screenshot1 = viewModel.screenshots.first else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(screenshot1.state, .loaded)
        XCTAssertEqual(screenshot1.image, mockImageStore.imageToReturn)
    }
    
    func testLoadingScreenshotIdsFromOfflineDataAndImageFromRemote() async {
        viewModel = GameScreenshotsViewModel(game: mockGame, coverPhotoLoader: coverPhotoLoader, repository: mockRepository)
        
        XCTAssertEqual(viewModel.screenshots.count, 0)
        
        mockCoverPhotoService.shouldFail = true
        mockImageStore.imageToReturn = nil
        mockImageDownloadService.imageToReturn = UIImage()
        
        // Save the game first in database
        do {
            try await mockRepository.save(model: mockGame)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        await viewModel.fetchScreenshots()
        
        XCTAssertEqual(viewModel.screenshots.count, 1)
        XCTAssertEqual(viewModel.screenshots.first?.state, .loading)
        
        if let screenshot = viewModel.screenshots.first {
            await viewModel.loadScreenshot(for: screenshot)
        }
        
        guard let screenshot1 = viewModel.screenshots.first else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(screenshot1.state, .loaded)
        XCTAssertEqual(screenshot1.image, mockImageStore.imageToReturn)
    }

}
