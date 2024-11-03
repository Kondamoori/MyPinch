//
//  GamesListCoordinator.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation
import UIKit
import SwiftUI

final class GamesListCoordinator {
    
    // MARK: - Private properties
    
    private let navigationController: UINavigationController
    private let appConfiguration: AppConfiguration
    private var detailsCoordinator: GameDetailCoordinator?
    private var gamesListViewController: UIViewController?
    private let coverPhotoLoader: CoverPhotoLoader

    
    // MARK: - Initialisation
    
    init(navigationController: UINavigationController, appConfiguration: AppConfiguration) {
        self.navigationController = navigationController
        self.appConfiguration = appConfiguration
        self.coverPhotoLoader = CoverPhotoLoader()
    }
    
}

// MARK: - Coordinating

extension GamesListCoordinator: Coordinating {
    
    func start() -> UIViewController {
        let viewModel = GameListViewModel(gamesService: GamesListService(requestManager: appConfiguration.requestManger), repository: CoreDataRepository(), requestManager: appConfiguration.requestManger, coverPhotoLoader: coverPhotoLoader, onGameSelected: { [weak self] game, coverImageId in
            self?.gotoGameDetails(game: game, coverImageId: coverImageId)
        })
        
        let listViewController = UIHostingController(rootView: GamesGridView(viewModel: viewModel))
        gamesListViewController = listViewController
        return listViewController
    }
    
    @MainActor
    func gotoGameDetails(game: Game, coverImageId: String?) {
        let detailsCoordinator = GameDetailCoordinator(navigationController: navigationController, game: game, coverImageId: coverImageId, coverPhotoLoader: coverPhotoLoader)
        let detailsViewController = detailsCoordinator.start()
        self.detailsCoordinator = detailsCoordinator
        navigationController.pushViewController(detailsViewController, animated: true)
    }

}
