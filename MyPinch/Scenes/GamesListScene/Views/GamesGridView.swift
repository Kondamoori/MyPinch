//
//  GamesGridView.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation
import SwiftUI

struct GamesGridView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let gridMinimumSpacing: CGFloat = 180
        static let gridSpacing: CGFloat = 15
        static let navigationTitle = LocalizedTranslator.GamesListScene.sceneTitle
        static let backgroundColor = Color(hex: 0xF3F6F9)
    }
    
    // MARK: - Internal properties
    @ObservedObject var viewModel: GameListViewModel
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var gridContent: AnyView = AnyView(EmptyView())
    
    // MARK: - View Body
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: Constants.gridMinimumSpacing), spacing: .zero)], spacing: Constants.gridSpacing) {
                gridContent
            }
            .padding([.top, .bottom], 8)
            .background(Constants.backgroundColor)
            .onChange(of: viewModel.state) { oldState, newState in
                handleStateChange(newState)
            }
            .onReceive(viewModel.$state) { value in
                handleStateChange(value)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text(LocalizedTranslator.AlertTranslation.ok))
                )
            }
        }
        .onAppear {
            handleStateChange(viewModel.state)
        }
        .navigationTitle(Constants.navigationTitle)
        .refreshable {
            viewModel.refreshData()
        }
    }
    
    // MARK: -  Private functions.
    
    /// Organise state changes
    private func handleStateChange(_ state: GameListViewModel.State) {
        switch state {
        case .loading:
            gridContent = AnyView(
                ForEach((0..<10).map { String($0) }, id: \.self) { _ in
                    ShimmerCellView()
                }
            )
            showAlert = false
        case .readyToDisplay, .offlineData:
            gridContent = AnyView(
                ForEach(viewModel.gamesData.indices, id: \.self) { index in
                    GameCardView(gameViewModel: viewModel.gamesData[index])
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        checkIfShouldLoadMoreContent(geometry: geometry, index: index)
                                    }
                            }
                        )
                        .onTapGesture {
                            viewModel.gameSelectionHandler?(viewModel.gamesData[index].game , viewModel.gamesData[index].coverImageId)
                        }
                }
            )
            showAlert = false
            
        case .noResults:
            showAlertForState(title: LocalizedTranslator.AlertTranslation.error, message: LocalizedTranslator.GamesListScene.failedToFetchGames)
            gridContent = AnyView(EmptyView())
            showAlert = true
    
        case .error:
            showAlertForState(title: LocalizedTranslator.AlertTranslation.error, message: LocalizedTranslator.GamesListScene.failedToFetchGames)
            showAlert = true
            if viewModel.gamesData.isEmpty {
                gridContent = AnyView(EmptyView())
            }
        }
    }
    
    private func showAlertForState(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    private func checkIfShouldLoadMoreContent(geometry: GeometryProxy, index: Int) {
        let frame = geometry.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height
        
        // Trigger loading when the view is within 200 points from the bottom of the screen
        if frame.maxY > screenHeight - 200 {
            viewModel.checkAndLoadMoreContentIfNeeded(index: index)
        }
    }
}

#if DEBUG
fileprivate enum PreviewScenario {
    case successCase, errorCase
}

#Preview {
    let scenario: PreviewScenario = .successCase
    let mockGame = Game(id: 131913, name: "Maji Kyun! Renaissance", rating: 0.0, storyLine: "In a world where art becomes magic", summary: "A cross media collaboration project between Sunrise & Broccolli.", coverId: 267633, checksum: UUID(), coverPhotoModel: nil)
    let mockGameListService = MockGamesListService()
    
    switch scenario {
    case .successCase:
        mockGameListService.gamesToReturn = Array.init(repeating: mockGame, count: 10)
        var viewModel = GameListViewModel(gamesService: mockGameListService, repository: nil, requestManager: AppConfiguration.default.requestManger, coverPhotoLoader: CoverPhotoLoader()) { _, _ in }

        let cardViewModel = GameCardViewModel(game: mockGame, coverPhotoLoader: CoverPhotoLoader())
        viewModel.gamesData = Array.init(repeating: cardViewModel, count: 10)
        return GamesGridView(viewModel: viewModel)
    case .errorCase:
        mockGameListService.shouldFail = true
        var viewModel = GameListViewModel(gamesService: MockGamesListService(), repository: nil,
            requestManager: AppConfiguration.default.requestManger, coverPhotoLoader: CoverPhotoLoader()) { _, _ in }
        viewModel.state = .loading
        return GamesGridView(viewModel: viewModel)
    }
}

#endif
