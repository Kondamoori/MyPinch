//
//  AppCoordinator.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation
import UIKit

@MainActor
protocol Coordinating {
    func start() -> UIViewController
}

final class AppCoordinator: Coordinating {
    
    // MARK: - Private properties
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let appConfiguration: AppConfiguration
    
    var gamesListCoordinator: GamesListCoordinator?
    
    // MARK: - Initialisation
    
    init(window: UIWindow, navigationController: UINavigationController = UINavigationController(), appConfiguration: AppConfiguration) {
        self.window = window
        self.navigationController = navigationController
        self.appConfiguration = appConfiguration
    }
    
    // MARK: - Coordinating
    
    func start() -> UIViewController {
        let gamesListCoordinator = GamesListCoordinator(navigationController: navigationController, appConfiguration: appConfiguration)
        self.gamesListCoordinator = gamesListCoordinator
        navigationController.viewControllers = [gamesListCoordinator.start()]
        return navigationController
    }
}
