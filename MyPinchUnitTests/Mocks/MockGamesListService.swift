//
//  MockGamesListService.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 28/10/2024.
//

import Foundation
import UIKit

class MockGamesListService: GamesListServiceProtocol {
    
    var shouldDelayRequest: Bool = false
    var gamesToReturn: [Game]?
    var shouldFail = false

    func fetchGames(endPoint: GamesEndPoint) async throws -> [Game]? {
        if shouldFail {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        }
        
        if shouldDelayRequest {
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        }
        return gamesToReturn
    }
}


class MockRequestManager: ApiRequestManagerInterface {
    func performRequest<T: Decodable>(endPoint: EndPoint) async throws -> T {
        return try JSONDecoder().decode(T.self, from: Data())
    }
}
