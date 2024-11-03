//
//  AppCoordinatorTests.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 03/11/2024.
//

import XCTest
@testable import MyPinch

@MainActor
final class AppCoordinatorTests: XCTestCase {

    func testAppCoordinatorIsStartingTheFlow() {
        let mockGame = Game(id: 131913, name: "Maji Kyun! Renaissance", rating: 0.0, storyLine: "In a world where art becomes magic", summary: "A cross media collaboration project between Sunrise & Broccolli.", coverId: 267633, checksum: UUID(), coverPhotoModel: nil)

        let navigationController = UINavigationController()
        let sut = AppCoordinator(window: UIWindow(), navigationController: navigationController, appConfiguration: AppConfiguration.default)
        XCTAssertNotNil(sut.start())
        
        XCTAssertNotNil(sut.gamesListCoordinator)
        sut.gamesListCoordinator?.gotoGameDetails(game: mockGame, coverImageId: "267633")
        
        XCTAssertEqual(navigationController.viewControllers.count, 1)
    }
}
