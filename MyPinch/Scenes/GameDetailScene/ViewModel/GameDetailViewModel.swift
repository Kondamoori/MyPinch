//
//  GameDetailViewModel.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 22/10/2024.
//

import Foundation
import SwiftUI

final class GameDetailViewModel: ObservableObject {
    
    // MARK: - Constants
    
    private enum Constants {
        static let hdImageSuffix = "_hd"
    }
    
    // MARK: - Internal properties
    
    @Published var coverImage: Image?
    
    let game: Game
    let gameCoverImageId: String?
    let repository: CoreDataRepository<Game>?
    var placeHolderImage = Image("dice")
    let coverPhotoLoader: CoverPhotoLoaderProtocol
    
    var gameName: String {
        game.name ?? "Unknown Name"
    }
    
    var gameSummary: String {
        game.summary ?? "Unknown summary"
    }
    
    // MARK: - Init
    
    init(game: Game,
         coverImageId: String?,
         coverPhotoLoader: CoverPhotoLoaderProtocol,
         repository: CoreDataRepository<Game>? = nil) {
        self.game = game
        self.coverPhotoLoader = coverPhotoLoader
        self.gameCoverImageId = coverImageId
        self.repository = repository
    }

    // MARK: - Internal functions
    
    @MainActor
    func loadImage() async {
        guard let gameCoverImageId else {
            await fetchCoverPhotoDataAndLoadImage()
            return
        }
        
        // Check from data store
        if let uiImage = coverPhotoLoader.imageStorage.getImage(for: gameCoverImageId+Constants.hdImageSuffix) {
            coverImage = Image(uiImage: uiImage)
            return
        }
        
        // Load image form backend
        let image = await loadImageFromCoverPhotId(coverImageId: gameCoverImageId)
    
        if let image {
            coverImage = Image(uiImage: image)
            coverPhotoLoader.imageStorage.saveImage(for: gameCoverImageId+Constants.hdImageSuffix, with: image)
        } else {
            await fetchCoverPhotoDataAndLoadImage()
        }
    }
    
    @MainActor
    func fetchCoverPhotoDataAndLoadImage() async {
        do {
            let coverPhotos = try await coverPhotoLoader.coverPhotoDataDownloadService.fetchCoverPhotosData(endPoint: .coverPhoto(gameId: String(game.id)))
            guard let coverImageId = coverPhotos.first?.image_id, let image = await loadImageFromCoverPhotId(coverImageId: coverImageId) else {
                coverImage = placeHolderImage
                return
            }
            
            coverImage = Image(uiImage: image)
            coverPhotoLoader.imageStorage.saveImage(for: coverImageId+Constants.hdImageSuffix, with: image)
        } catch {
            coverImage = placeHolderImage
        }
    }
    
    // MARK: - Private functions
    
    private func loadImageFromCoverPhotId(coverImageId: String) async -> UIImage? {
        guard let imageUrl = ImageURLBuilder.buildImageURL(imageID: coverImageId, size: .hd, imageType: .PNG), let image = try? await coverPhotoLoader.imageDownloadService.downloadImage(url: imageUrl) else { return nil }
        return image
    }
}
