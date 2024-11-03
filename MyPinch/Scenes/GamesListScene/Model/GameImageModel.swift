//
//  GameImageModel.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 22/10/2024.
//

import Foundation
import CoreData

struct GameImageModel: Decodable, Hashable {
    let id: Int64
    let image_id: String?
}

extension GameImageModel: Persistable {
    
    var primaryKey: Int64 {
        id
    }
    
    func toEntity(in context: NSManagedObjectContext) -> GameImageEntity {
        let entity = GameImageEntity(context: context)
        entity.id = id
        entity.image_id = image_id
        return entity
    }
    
    static func fromEntity(_ entity: Entity) -> Self {
        return GameImageModel(id: entity.id, image_id: entity.image_id)
    }
    
    func updateEntity(_ entity: GameImageEntity, context: NSManagedObjectContext) -> GameImageEntity {
        entity.image_id = image_id
        return entity
    }
}
