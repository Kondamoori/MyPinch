//
//  ApiRequestManager.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation

protocol ApiRequestManagerInterface {
    func performRequest<T: Decodable>(endPoint: EndPoint) async throws -> T
}


final class ApiRequestManager {
    
    // MARK: - Request configuration
    
    struct ApiRequestConfiguration {
        let baseURL: URL?
        let baseHeaders: [String: String]
        
        public init(baseURL: URL?, baseHeaders: [String: String]) {
            self.baseURL = baseURL
            self.baseHeaders = baseHeaders
        }
        
        public static let `default` = ApiRequestConfiguration(baseURL: nil, baseHeaders: [:])
    }
    
    // MARK: - Internal properties
    
    private let requestConfiguration: ApiRequestConfiguration
    
    // MARK: - Initialisation
    
    init(requestConfiguration: ApiRequestConfiguration) {
        self.requestConfiguration = requestConfiguration
    }
    
}

extension ApiRequestManager: ApiRequestManagerInterface {
    
    func performRequest<T>(endPoint: any EndPoint) async throws -> T where T : Decodable {
        
        guard Reachability.isConnectedToNetwork() else {
            throw NetworkError.noInternet
        }
        
        guard let request = buildURLRequest(endPoint: endPoint) else {
            throw ApiError.requestError
        }
        
        
        let (responseData, httpResponse) = try await URLSession.shared.data(for: request)
        
        let data = try parseHttpResponse(response: (responseData, httpResponse))
        do {
            let jsonData = try JSONDecoder().decode(T.self, from: data)
            return jsonData
        } catch {
            throw ApiError.parsingError
        }
    }
    
    private func buildURLRequest(endPoint: EndPoint) -> URLRequest? {
        let host = endPoint.baseURL?.host ?? requestConfiguration.baseURL?.host
        guard let host = host else { return nil }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = endPoint.path
        
        if let urlQueries = endPoint.queryParameters {
            var queryItems: [URLQueryItem] = []
            for item in urlQueries {
                queryItems.append(URLQueryItem(name: item.name, value: item.value))
            }
            
            components.queryItems = queryItems
        }
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method.rawValue
        
        let endPointHeaders = endPoint.headers ?? [:]
        let mergedHeaders = requestConfiguration.baseHeaders.merging(endPointHeaders) { (_, new) in new }
        request.allHTTPHeaderFields = mergedHeaders
        
        if let data = endPoint.body {
            request.httpBody = data
        }
        
        return request
    }
    
    /// Function to parse HTTP Response from perform request of NetworkRequestManager.
    /// - Parameter response: response object with (Data, URLResponse)
    /// - Returns: instance of Data if httpResponse.statusCode 200..<300.
    func parseHttpResponse(response: (data: Data, response: URLResponse)) throws -> Data {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return response.data
        case 400:
            throw ApiError.requestError
        case 401:
            throw ApiError.unAuthorized
        case 403:
            throw ApiError.forbidden
        case 404:
            throw ApiError.notFound
        default:
            throw ApiError.unknownError(httpResponse: httpResponse, data: response.data)
        }
    }

}


