//
//  GameDetailCoordinator.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 22/10/2024.
//

import Foundation
import UIKit
import SwiftUI

final class GameDetailCoordinator {
    
    // MARK: - Private properties
    
    private let navigationController: UINavigationController
    private let game: Game
    private let coverImageId: String?
    private let coverPhotoLoader: CoverPhotoLoaderProtocol
    private var gameDetailsController: UIViewController?
    
    // MARK: - Init
    
    init(navigationController: UINavigationController,
         game: Game,
         coverImageId: String?,
         coverPhotoLoader: CoverPhotoLoaderProtocol) {
        self.navigationController = navigationController
        self.game = game
        self.coverImageId = coverImageId
        self.coverPhotoLoader = coverPhotoLoader
    }
}

// Extension - Coordinating

extension GameDetailCoordinator: Coordinating {
    
    // MARK: - Start
    
    func start() -> UIViewController {
        let gameDetailsView = GameDetailsView(viewModel: GameDetailViewModel(game: game, coverImageId: coverImageId, coverPhotoLoader: coverPhotoLoader, repository: CoreDataRepository()))
        let detailsController = UIHostingController(rootView: gameDetailsView)
        gameDetailsController = detailsController
        return detailsController
    }
}
