//
//  APIError.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation

/// Custom Error type
enum ApiError: Error, LocalizedError, Equatable {
    case invalidRequest
    case requestError
    case invalidResponse
    case parsingError
    case unAuthorized
    case forbidden
    case notFound
    case unknownError(httpResponse: HTTPURLResponse, data: Data)
    
    // For user feedback
    var localizedDescription: String {
        switch self {
        case .invalidRequest:
            return "Failed to create request"
        case .requestError,
                .invalidResponse,
                .parsingError,
                .unAuthorized,
                .forbidden,
                .notFound,
                .unknownError:
            return "Sorry, something went wrong."
        }
    }
    
    // For internal feedback
    var description: String {
        switch self {
        case .invalidRequest: return "invalid request"
        case .requestError: return "request error"
        case .invalidResponse, .unknownError: return "invalid Response"
        case .parsingError: return "parsing error"
        case .unAuthorized: return "Access restricted"
        case .forbidden, .notFound : return "Resource not found"
        }
    }

}
