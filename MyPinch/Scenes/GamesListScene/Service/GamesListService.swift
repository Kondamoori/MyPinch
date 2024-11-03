//
//  GamesListService.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation

protocol GamesListServiceProtocol {
    func fetchGames(endPoint: GamesEndPoint) async throws -> [Game]?
}

final class GamesListService {
    
    // MARK: - Private properties
    
    private let requestManger: ApiRequestManagerInterface
    
    // MARK: - Initialisation
    
    init(requestManager: ApiRequestManagerInterface) {
        self.requestManger = requestManager
    }
}

// MARK: - GameListServiceProtocol

extension GamesListService: GamesListServiceProtocol {
    
    func fetchGames(endPoint: GamesEndPoint) async throws -> [Game]? {
        do {
            return try await requestManger.performRequest(endPoint: endPoint)
        } catch {
            throw error
        }
    }
}
