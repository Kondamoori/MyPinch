//
//  ImagesEndPoint.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 22/10/2024.
//

import Foundation

enum ImagesEndPoint: EndPoint {
    
    case coverPhoto(gameId: String)
    case screenshots(gameId: String)
    
    // MARK: - Constants
    
    private enum Constants {
        static let fetchFields = "fields image_id;"
        static let coverPhotoPath = "/v4/covers"
        static let screenshotsPath = "/v4/screenshots"
    }
    
    var headers: [String : String]? {
        return ["Accept" : contentType.rawValue]
    }
    
    var baseURL: URL? {
        nil
    }
    
    var path: String {
        switch self {
        case .coverPhoto:
            return Constants.coverPhotoPath
        case .screenshots:
            return Constants.screenshotsPath
        }
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var body: Data? {
        switch self {
        case .coverPhoto(let gameId):
            let query = """
                \(Constants.fetchFields)
                where game=\(gameId);
                """
            return query.data(using: .utf8, allowLossyConversion: false)
        case .screenshots(let gameId):
            let query = """
                \(Constants.fetchFields)
                where game=\(gameId);
                """
            return query.data(using: .utf8, allowLossyConversion: false)
        }
    }
    
    var contentType: ContentType {
        .JSON
    }
    
    var queryParameters: [URLQueryItem]? {
        return nil
    }
}
