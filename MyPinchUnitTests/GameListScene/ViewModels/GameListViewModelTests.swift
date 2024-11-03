//
//  GameListViewModelTests.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 28/10/2024.
//

import XCTest
import CoreData
import Combine
@testable import MyPinch

@MainActor
class GameListViewModelTests: XCTestCase {
    
    var viewModel: GameListViewModel!
    var mockService = MockGamesListService()
    let mockGame = Game(id: 131913, name: "Maji Kyun! Renaissance", rating: 0.0, storyLine: "In a world where art becomes magic", summary: "A cross media collaboration project between Sunrise & Broccolli.", coverId: 267633, checksum: UUID(), coverPhotoModel: nil)
    var cancellables: Set<AnyCancellable> = []
    lazy var mockRepository: CoreDataRepository<Game> = {
        let context = CoreDataStackTests.makeInMemoryContext()
        return CoreDataRepository(context: context)
    }()
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testFetchGamesSuccess() async {
        viewModel = GameListViewModel(gamesService: mockService, repository: mockRepository, requestManager: MockRequestManager(), coverPhotoLoader: MockCoverPhotoLoader(), onGameSelected: nil)
        mockService.gamesToReturn = [mockGame, mockGame]
        await viewModel.fetchGames()
        XCTAssertEqual(viewModel.state, .readyToDisplay)
        XCTAssertEqual(viewModel.gamesData.count, 2)
    }
    
    func testFetchGamesFailureWithNoOfflineDataExist() async {
        viewModel = GameListViewModel(gamesService: mockService, repository: mockRepository, requestManager: MockRequestManager(), coverPhotoLoader: MockCoverPhotoLoader(), onGameSelected: nil)
        mockService.shouldFail = true
        await viewModel.fetchGames()
        XCTAssertEqual(viewModel.state, .error)
        XCTAssertEqual(viewModel.gamesData.count, 0)
    }

    func testFetchGamesEmptyResults() async {
        viewModel = GameListViewModel(gamesService: mockService, repository: mockRepository, requestManager: MockRequestManager(), coverPhotoLoader: MockCoverPhotoLoader(), onGameSelected: nil)
        mockService.gamesToReturn = []
        await viewModel.fetchGames()
        XCTAssertEqual(viewModel.state, .error)
    }

    func testFetchGamesOfflineLoad() async {
        viewModel = GameListViewModel(gamesService: mockService, repository: mockRepository, requestManager: MockRequestManager(), coverPhotoLoader: MockCoverPhotoLoader(), onGameSelected: nil)
        mockService.shouldFail = true
        do {
            try await mockRepository.save(model: mockGame)
        } catch {
            XCTFail()
        }
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        viewModel.refreshData()
        await viewModel.fetchGames()
        XCTAssertEqual(viewModel.state, .readyToDisplay)
        XCTAssertEqual(viewModel.gamesData.count, 1)
    }

    func testShouldLoadMoreContent() async {
        viewModel = GameListViewModel(gamesService: mockService, repository: mockRepository, requestManager: MockRequestManager(), coverPhotoLoader: MockCoverPhotoLoader(), onGameSelected: nil)
        mockService.gamesToReturn = Array(repeating: mockGame, count: 20)
        await viewModel.fetchGames()
        
        viewModel.checkAndLoadMoreContentIfNeeded(index: (0..<18).randomElement()!)
        XCTAssertEqual(viewModel.loadMore, false)

        viewModel.checkAndLoadMoreContentIfNeeded(index: 19)
        XCTAssertEqual(viewModel.loadMore, true)
    }
    
    func testCallingFetchGamesWhilePreviousRequestIsInProgress() async {
        let mockService = MockGamesListService()
        mockService.gamesToReturn = Array(repeating: mockGame, count: 20)
        viewModel = GameListViewModel(gamesService: mockService, repository: mockRepository, requestManager: MockRequestManager(), coverPhotoLoader: MockCoverPhotoLoader(), onGameSelected: nil)
        mockService.shouldDelayRequest = true
        async let task1: () = await self.viewModel.fetchGames()
        async let task2: () = await self.viewModel.fetchGames()
        
        let _ = await(task1, task2)
        XCTAssertTrue(viewModel.gamesData.isEmpty)
    }
    
    func testRefreshIsResettingTheExistingDataSet() async {
        viewModel = GameListViewModel(gamesService: mockService, repository: mockRepository, requestManager: MockRequestManager(), coverPhotoLoader: MockCoverPhotoLoader(), onGameSelected: nil)

        mockService.gamesToReturn = Array(repeating: mockGame, count: 20)
        await viewModel.fetchGames()
        
        XCTAssertEqual(viewModel.gamesData.count, 20)
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.gamesData.count, 0)
    }

    func testDataBaseIsRejectingDuplicateEntries() async {
        viewModel = GameListViewModel(gamesService: mockService, repository: mockRepository, requestManager: MockRequestManager(), coverPhotoLoader: MockCoverPhotoLoader(), onGameSelected: nil)

        mockService.gamesToReturn = Array(repeating: mockGame, count: 20)
        await viewModel.fetchGames()
        
        let databaseGames = try? await mockRepository.fetchAll()
        XCTAssertEqual(viewModel.gamesData.count, 20)
        
        // We should have only count 1 since all are with same id.
        XCTAssertEqual(databaseGames?.count, 1)
    }
    
    func testDataBaseIsInSyncWithGamesFetch() async {
        viewModel = GameListViewModel(gamesService: mockService, repository: mockRepository, requestManager: MockRequestManager(), coverPhotoLoader: MockCoverPhotoLoader(), onGameSelected: nil)

        mockService.gamesToReturn = (0..<20).map { Game(id: $0, name: "Maji Kyun! Renaissance", rating: 0.0, storyLine: "In a world where art becomes magic", summary: "A cross media collaboration project between Sunrise & Broccolli.", coverId: 267633, checksum: UUID(), coverPhotoModel: nil) }
        await viewModel.fetchGames()
        
        let databaseGames = try? await mockRepository.fetchAll()
        XCTAssertEqual(viewModel.gamesData.count, 20)
        
        // We should have 20 since all are with different id.
        XCTAssertEqual(databaseGames?.count, 20)
        
        // To provide another set of 20 with diff id.
        mockService.gamesToReturn = (20..<40).map { Game(id: $0, name: "Maji Kyun! Renaissance", rating: 0.0, storyLine: "In a world where art becomes magic", summary: "A cross media collaboration project between Sunrise & Broccolli.", coverId: 267633, checksum: UUID(), coverPhotoModel: nil) }

        await viewModel.fetchGames()
        
        let databaseGamesFetch2 = try? await mockRepository.fetchAll()
        XCTAssertEqual(viewModel.gamesData.count, 40)
        
        // We should have 20 since all are with different id.
        XCTAssertEqual(databaseGamesFetch2?.count, 40)
    }
}
