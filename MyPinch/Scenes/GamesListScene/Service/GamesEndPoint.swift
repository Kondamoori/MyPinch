//
//  GamesEndPoint.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation

enum GamesEndPoint: EndPoint {
    
    // MARK: - Constants
    
    private enum Constants {
        static let fetchFields = "fields *"
        static let path = "/v4/games"
    }

    case fetchGames(offset: Int, limit: Int)
    case gameDetails(gameId: String)
    
    // MARK: - Internal properties
    
    var headers: [String : String]? {
        return ["Accept" : contentType.rawValue]
    }
    
    var baseURL: URL? {
        nil
    }
    
    var path: String {
        return Constants.path
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var body: Data? {
        switch self {
        case .fetchGames(let offset, let limit):
            let query = """
                \(Constants.fetchFields);
                limit \(limit);
                offset \(offset);
                """
            return query.data(using: .utf8, allowLossyConversion: false)
        case .gameDetails(_):
            return nil
        }
    }
    
    var contentType: ContentType {
        .JSON
    }
    
    var queryParameters: [URLQueryItem]? {
        return nil
    }
}
