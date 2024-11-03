//
//  ImageDownloadManager.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 22/10/2024.
//

import Foundation
import UIKit

/// ImageDownloadError
enum ImageDownloadError: Error, LocalizedError, Equatable {
    case invalidResponse
    case invalidData
    case downloadError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "invalid response from server"
        case .invalidData:
            return "invalid data in response"
        case .downloadError:
            return "image download error"
        }
    }
}

protocol ImageDownloadServiceProtocol {
    func downloadImage(url: URL) async throws -> UIImage?
}

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}


/// ImageDownloadManager, to organise image downloads and share it w
actor ImageDownloadManager: ImageDownloadServiceProtocol {
    
    // MARK: - Shared instance
    static let shared = ImageDownloadManager()
    
    // MARK: - Private properties
    
    private let session: URLSessionProtocol
    private var tasks: [String: Task<UIImage?, Error>] = [:]
    
    // MARK: - Private init.
    
    internal init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Internal functions
    
    /// Function to download image for given URL. This function will creates a task each time when you call this url and keeps
    /// - Parameter url: image source url.
    /// - Returns: return optional UIImage.
    func downloadImage(url: URL) async throws -> UIImage? {
        
        let existingTask = tasks[url.absoluteString]
        
        if let existingTask {
            return try await existingTask.value
        }
        
        let task = Task { () -> UIImage? in
            
            do {
                // Check for task cancelation
                try Task.checkCancellation()
                
                let error: ImageDownloadError
                let (data, response) = try await session.data(from: url)
                
                // Check cancelation status after fetching data
                
                try Task.checkCancellation()
                
                // Validate response
                if isValidResponse(urlResponse: response) {
                    guard let image = UIImage(data: data) else {
                        error = .invalidData
                        throw error
                    }
                    
                    if Task.isCancelled {
                        throw CancellationError()
                    }
                    
                    return image
                } else {
                    throw ImageDownloadError.invalidResponse
                }
            } catch {
                if Task.isCancelled {
                    throw CancellationError()
                }
                
                throw error
            }
        }
        
        tasks[url.absoluteString] = task
        
        let image = try await task.value
        
        tasks.removeValue(forKey: url.absoluteString)
    
        return image
    }
    
    func cancelImageDownload(url: URL) {
        guard let task = tasks[url.absoluteString] else {
            return
        }
        
        task.cancel()
        tasks.removeValue(forKey: url.absoluteString)
    }
        
    private func isValidResponse(urlResponse: URLResponse) -> Bool {
        guard let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        
        return true
    }
}

extension URLSession: URLSessionProtocol { }
