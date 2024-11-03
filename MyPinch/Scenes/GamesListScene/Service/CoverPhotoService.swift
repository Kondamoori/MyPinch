//
//  CoverPhotoService.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 22/10/2024.
//

import Foundation
import SwiftUI

protocol CoverPhotoServiceProtocol {
    func fetchCoverPhotosData(endPoint: ImagesEndPoint) async throws -> [GameImageModel]
}

final class CoverPhotoService: CoverPhotoServiceProtocol {
        
    // MARK: - Private properties
    
    private let requestManger: ApiRequestManagerInterface
    
    // MARK: - Initialisation
    
    init(requestManager: ApiRequestManagerInterface) {
        self.requestManger = requestManager
    }
    
    func fetchCoverPhotosData(endPoint: ImagesEndPoint) async throws -> [GameImageModel] {
       return try await requestManger.performRequest(endPoint: endPoint)
    }
}
