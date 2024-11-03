//
//  GameScreenshotsViewModel.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 31/10/2024.
//

import Foundation
import SwiftUI

@MainActor
final class GameScreenshotsViewModel: ObservableObject {
    
    // MARK: - Constants
    
    private enum Constants {
        static let screenshotSuffix = "_screenshot"
    }
    
    // MARK: - Internal properties
    
    @Published var screenshots: [Screenshot] = []
    
    // MARK: - Private properties
    
    private let game: Game
    private let coverPhotoLoader: CoverPhotoLoaderProtocol
    private let repository: CoreDataRepository<Game>?
    
    // MARK: - Init
    
    init(game: Game, coverPhotoLoader: CoverPhotoLoaderProtocol, repository: CoreDataRepository<Game>? = nil) {
        self.game = game
        self.coverPhotoLoader = coverPhotoLoader
        self.repository = repository
        
        Task {
            await fetchScreenshots()
        }
    }
            
    // MARK: - Internal functions
    
    @MainActor
    func fetchScreenshots() async {
        // Load images from backend first
        guard let screenshotsData = await fetchScreenshotIdsFromBackend(), !screenshotsData.isEmpty else {
            
            // check offline image ids
            if let offlineModels = await fetchScreenshotIdsFromOfflineData(), !offlineModels.isEmpty {
                let imageIds = offlineModels.compactMap { $0.image_id }
                await MainActor.run {
                    screenshots = makeScreenshots(imageIds: imageIds)
                }
            }
            
            return
        }
        
        await storeScreenshotData(data:screenshotsData)
        let imageIds = screenshotsData.compactMap { $0.image_id }
        screenshots = makeScreenshots(imageIds: imageIds)
    }

    // Fetch image for a specific screenshot and update its state accordingly
    @MainActor
    func loadScreenshot(for screenshot: Screenshot) async {
        guard let index = screenshots.firstIndex(where: { $0.id == screenshot.id }) else { return }
        do {
            if screenshots[index].image != nil {
                screenshots[index].state = .loaded
            } else if let url = screenshots[index].url, let image = try await coverPhotoLoader.imageDownloadService.downloadImage(url: url) {
                await MainActor.run {
                    screenshots[index].image = image
                }
                coverPhotoLoader.imageStorage.saveImage(for: screenshots[index].id+Constants.screenshotSuffix, with: image)
                screenshots[index].state = .loaded
            }
        } catch {
            screenshots[index].state = .failed
        }
        
    }

    
    // MARK: - Private functions
    
    private func fetchScreenshotIdsFromOfflineData() async -> [GameImageModel]? {
        await fetchGameFromRepository()?.screenshots
    }

    private func fetchScreenshotIdsFromBackend() async -> [GameImageModel]? {
        return try? await coverPhotoLoader.coverPhotoDataDownloadService.fetchCoverPhotosData(endPoint: .screenshots(gameId: String(game.id)))
    }
    
    private func makeScreenshots(imageIds: [String]) -> [Screenshot] {
        return imageIds.map { imageId in
            let imageURL = ImageURLBuilder.buildImageURL(imageID: imageId, size: .cover_image_big, imageType: .PNG)
            let image = coverPhotoLoader.imageStorage.getImage(for: imageId+Constants.screenshotSuffix)
            return Screenshot(id: imageId, url: imageURL, image: image, state: .loading)
        }
    }
    
    private func storeScreenshotData(data: [GameImageModel]) async {
        if var game = await fetchGameFromRepository() {
            game.screenshots = data
            try? await repository?.save(model: game)
        }
    }
    
    private func fetchGameFromRepository() async -> Game? {
        let predicate = NSPredicate(format: "id == %ld", game.id)
        let game = try? await repository?.fetchAll(predicate: predicate).first
        return game
    }
}
