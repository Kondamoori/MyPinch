//
//  GameListViewModel.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import SwiftUI
import Combine

typealias GameSelectionHandler = ((Game, _ coverPhotoId: String?) -> Void)?

@MainActor
final class GameListViewModel: ObservableObject {
    
    // MARK: - Constants
    
    private enum Constants {
        static let fetchLimit = 10
    }
    
    // MARK: - State
    enum State: Equatable {
        case loading, readyToDisplay, noResults, error, offlineData, noAccessToData
    }
    
    // MARK: - Internal properties
    
    @Published var state : State = .loading
    @Published var gamesData: [GameCardViewModel] = []
    @Published var loadMore: Bool = false
    var gameSelectionHandler: GameSelectionHandler
    var isInitialLoad: Bool = true
    
    // MARK: - Private properties
    
    private var offset = 0
    private let gamesService: GamesListServiceProtocol
    private let repository: CoreDataRepository<Game>?
    private let requestManager: ApiRequestManagerInterface
    private let coverPhotoLoader: CoverPhotoLoaderProtocol
    
    private var shouldProceedToRequest: Bool {
        switch (state, isInitialLoad) {
        case (.loading, true): return true
        case (.loading, false): return false
        default:
            return true
        }
    }
        
    // MARK: - Initialisation
    
    init(gamesService: GamesListServiceProtocol,
         repository: CoreDataRepository<Game>?,
         requestManager: ApiRequestManagerInterface,
         coverPhotoLoader: CoverPhotoLoaderProtocol,
         onGameSelected: GameSelectionHandler) {
        self.gamesService = gamesService
        self.gameSelectionHandler = onGameSelected
        self.repository = repository
        self.requestManager = requestManager
        self.coverPhotoLoader = coverPhotoLoader
        
        Task{
            await fetchGames()
        }
    }
    
    //MARK: - Internal functions

    @MainActor
    func fetchGames() async {
        guard shouldProceedToRequest else { return }
        isInitialLoad = false
        do {
            guard let newGames = try await gamesService.fetchGames(endPoint: .fetchGames(offset: offset, limit: Constants.fetchLimit)), !newGames.isEmpty else {
                await fetchOfflineGamesAndUpdateState()
                return
            }
            
            gamesData.append(contentsOf: newGames.sorted(by: { $0.id < $1.id }).map({ game in
                GameCardViewModel(game: game, persistenceStore: repository, coverPhotoLoader: coverPhotoLoader)
            }))
            state = gamesData.isEmpty ? .noResults : .readyToDisplay
            
            try? await repository?.saveAll(models: newGames.sorted(by: { $0.id < $1.id }))
            
            loadMore = false
            offset = gamesData.count
        } catch let error as ApiError where error == .unAuthorized {
            state = .noAccessToData
            loadMore = false
        } catch {
            await fetchOfflineGamesAndUpdateState()
        }
    }
        
    func checkAndLoadMoreContentIfNeeded(index: Int) {
        guard gamesData.endIndex - 1 == index  else {
            return
        }
        
        offset = gamesData.endIndex
        loadMore = true
        Task { @MainActor [weak self] in
            guard let self else { return }
            await fetchGames()
        }
    }
    
    func refreshData() {
        resetData()
        state = .loading
        isInitialLoad = true
        Task { [weak self] in
            guard let self else { return }
            await fetchGames()
        }
    }
    
    // MARK: - Private functions
    
    private func fetchOfflineGamesAndUpdateState() async {
        if let offlineGamesData = try? await repository?.fetchBatch(offset: offset, limit: Constants.fetchLimit), !offlineGamesData.isEmpty {
            gamesData.append(contentsOf: offlineGamesData.sorted(by: { $0.id < $1.id }).map({ game in
                GameCardViewModel(game: game, persistenceStore: repository, coverPhotoLoader: coverPhotoLoader)
            }))
            offset = gamesData.count
            state = .readyToDisplay
        } else {
            state = .error
            loadMore = false
        }
    }
    
    private func resetData() {
        gamesData = []
        offset = 0
    }
}
