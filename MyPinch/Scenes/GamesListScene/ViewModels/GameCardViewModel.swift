//
//  GameCardViewModel.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 22/10/2024.
//

import Foundation
import SwiftUI
import CoreData


/// View model for game card view.

@MainActor
final class GameCardViewModel: ObservableObject {
    
    // MARK: - State
    
    enum ImageState {
        case loading, loaded, failed
    }
 
    // MARK: - Internal properties
    
    @Published var state: ImageState = .loading
    @Published var image: UIImage!
    private(set) var game: Game
    
    
    // MARK: - Private properties
    
    private var gameImageModel: GameImageModel?
    private let persistenceStore: CoreDataRepository<Game>?
    private let coverPhotoLoader: CoverPhotoLoaderProtocol
    
    var coverImageId: String? {
        gameImageModel?.image_id
    }

    // MARK: - Initialiser
    
    init(game: Game,
         persistenceStore: CoreDataRepository<Game>? = CoreDataRepository(),
         coverPhotoLoader: CoverPhotoLoaderProtocol) {
        self.game = game
        self.persistenceStore = persistenceStore
        self.coverPhotoLoader = coverPhotoLoader
    }
    
    // MARK: - Internal functions
    
    func loadImage() async {
        state = .loading
        
        // Check in memory image first, if the cell is reloading with existing data source.
        if let cachedImage = loadImageFromInMemoryCoverId() {
            image = cachedImage
            state = .loaded
            return
        }
        
        // Load from backend
        do {
            gameImageModel = try await fetchRemoteCoverPhotoData()
            guard let gameImageModel else {
                
                // Check offline data from persistence store to get image id and look into image cache.
                await loadCoverPhotImageFromOffline()
                return
            }
            
            // Download latest image from backend.
            await downloadImageFromCoverPhotoData(coverPhotoId: gameImageModel.image_id)
            
            // Save the latest image data into persistenceStore.
            game.coverImageModel = gameImageModel
            try? await persistenceStore?.save(model: game)
        } catch {
            await loadCoverPhotImageFromOffline()
        }
    }
    
    // MARK: - Private functions
    
    private func fetchRemoteCoverPhotoData() async throws -> GameImageModel? {
        try await coverPhotoLoader.coverPhotoDataDownloadService.fetchCoverPhotosData(endPoint: .coverPhoto(gameId: String(game.id))).first
    }
    
    @MainActor
    private func fetchGameImageModelFromPersistenceStore() async -> Game? {
        let predicate = NSPredicate(format: "id == %ld", game.id)
        do {
            let game = try await persistenceStore?.fetchAll(predicate: predicate).first
            return game
        } catch {
            return nil
        }
    }
    
    private func loadImageFromInMemoryCoverId() -> UIImage? {
        guard gameImageModel != nil, let imageId =  gameImageModel?.image_id, let imageFromCache = coverPhotoLoader.imageStorage.getImage(for: imageId) else {
            return nil
        }
        
        return imageFromCache
    }
    
    private func downloadImageFromCoverPhotoData(coverPhotoId: String?) async {
        guard let coverPhotoId, let imageUrl = ImageURLBuilder.buildImageURL(imageID: String(coverPhotoId), size: .cover_image_big, imageType: .PNG), let downloadedImage = try? await coverPhotoLoader.imageDownloadService.downloadImage(url: imageUrl) else {
            state = .failed
            return
        }
        
            image = downloadedImage
            coverPhotoLoader.imageStorage.saveImage(for: coverPhotoId, with: downloadedImage)
            state = .loaded
        }
    
    private func loadCoverPhotImageFromOffline() async {
        guard let persistedGame = await fetchGameImageModelFromPersistenceStore(), let image_id = persistedGame.coverImageModel?.image_id else {
            state = .failed
            return
        }
        
        gameImageModel = persistedGame.coverImageModel
        
        if let imageFromCache = coverPhotoLoader.imageStorage.getImage(for: image_id) {
            image = imageFromCache
            state = .loaded
        } else {
            await downloadImageFromCoverPhotoData(coverPhotoId: image_id)
        }
    }
}

