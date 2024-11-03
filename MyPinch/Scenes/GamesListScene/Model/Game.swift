//
//  Game.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation
import CoreData

struct Game: Decodable {
    let id: Int64
    let name: String?
    let rating: Double?
    let storyLine: String?
    let summary: String?
    let coverId: Int64?
    let checksum: UUID
   
    /// Properties used for database relations
    var screenshots: [GameImageModel]?
    var coverImageModel: GameImageModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case rating
        case storyLine = "storyline"
        case summary
        case coverId = "cover"
        case checksum
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 0
        self.storyLine = try container.decodeIfPresent(String.self, forKey: .storyLine)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
        self.coverId = try container.decodeIfPresent(Int64.self, forKey: .coverId)
        self.checksum = try container.decode(UUID.self, forKey: .checksum)
    }
    
 
    init(id: Int64, name: String?, rating: Double?, storyLine: String?, summary: String?, coverId: Int64?, checksum: UUID, screenshots: [GameImageModel]? = nil, coverPhotoModel: GameImageModel?) {
        self.id = id
        self.name = name
        self.rating = rating
        self.storyLine = storyLine
        self.summary = summary
        self.coverId = coverId
        self.checksum = checksum
        self.screenshots = screenshots
        self.coverImageModel = coverPhotoModel
    }
}

extension Game: Equatable {}

// MARK: - Persistable

extension Game: Persistable {
    
    /// Used as primary key to eliminate duplicates with core data constraints.
    var primaryKey: Int64 {
        id
    }
    
    /// Function to map model to entity
    /// - Parameter context: instance of NSManagedObject
    /// - Returns: returns instance of GameEntity.
    func toEntity(in context: NSManagedObjectContext) -> GameEntity {
        var coverImageEntity: GameImageEntity?
        if let coverImageModel {
            coverImageEntity = GameImageEntity(context: context)
            coverImageEntity?.id = coverImageModel.id
            coverImageEntity?.image_id = coverImageModel.image_id
        }
        
        let entity = GameEntity(context: context)
        entity.id = id
        entity.name = name
        entity.summary = summary
        entity.rating = rating ?? 0
        entity.coverId = coverId ?? 0
        entity.checksum = checksum
        entity.storyLine = storyLine
        
        let imageEntities = screenshots?.map { screenshot in
            let gameImageEntity = GameImageEntity(context: context)
            gameImageEntity.id = screenshot.id
            gameImageEntity.image_id = screenshot.image_id
            return gameImageEntity
        }
        entity.screenshots = NSSet(array: imageEntities ?? [])
        entity.coverImage = coverImageEntity
        return entity
    }
    
    /// Function to convert entity to model.
    /// - Parameter entity: entity to be converted.
    /// - Returns: return instance of Game.
    static func fromEntity(_ entity: Entity) -> Self {
        return Game(id: entity.id, name: entity.name, rating: entity.rating, storyLine: entity.storyLine, summary: entity.summary, coverId: entity.coverId, checksum: entity.checksum!, screenshots: getScreenshots(entity: entity), coverPhotoModel: gameCoverPhoto(entity: entity))
    }
    
    /// Function to update given entity with latest model properties
    /// - Parameters:
    ///   - entity: instance of entity needs to be updated.
    ///   - context: instance of NSManagedObjectContext
    /// - Returns: instance of updated GameEntity.
    func updateEntity(_ entity: GameEntity, context: NSManagedObjectContext) -> GameEntity {
        var coverImageEntity: GameImageEntity?
        if let coverImageModel {
            coverImageEntity = GameImageEntity(context: context)
            coverImageEntity?.id = coverImageModel.id
            coverImageEntity?.image_id = coverImageModel.image_id
        }

        if let screenshots {
            let screenshotEntities = screenshots.map { gameImageModel in
                gameImageModel.toEntity(in: context)
            }
            entity.screenshots = NSSet(array: screenshotEntities)
        }
        
        entity.name = name
        entity.summary = summary
        entity.rating = rating ?? 0
        entity.coverId = coverId ?? 0
        entity.checksum = checksum
        entity.storyLine = storyLine
        entity.coverImage = coverImageEntity
        return entity
    }
    
    static func getScreenshots(entity: Entity) -> [GameImageModel]? {
        guard let screenshots = entity.screenshots as? Set<GameImageEntity>, !screenshots.isEmpty else { return nil }
        let arrayOfGameImageModel: [GameImageModel] = Array(screenshots).map { gameImageEntity in
            GameImageModel(id: gameImageEntity.id, image_id: gameImageEntity.image_id)
            
        }
        
        return arrayOfGameImageModel.isEmpty ? nil : arrayOfGameImageModel
    }
        
    static func gameCoverPhoto(entity: Entity) -> GameImageModel? {
        guard let coverImage = entity.coverImage else { return nil }
        return GameImageModel.fromEntity(coverImage)
    }
}
