//
//  DatabaseProtocols.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 26/10/2024.
//

import Foundation
import CoreData

/// Protocol to define Persistable type
protocol Persistable {
    associatedtype Entity
    var primaryKey: Int64 { get }
    func updateEntity(_ entity: Entity, context: NSManagedObjectContext) -> Entity
    func toEntity(in context: NSManagedObjectContext) -> Entity
    static func fromEntity(_ entity: Entity) -> Self
}

/// Protocol to define local database capabilities
protocol Repository {
    associatedtype Model
    func save(model: Model) async throws
    func fetchAll() async throws -> [Model]
    func fetchAll(predicate: NSPredicate?) async throws -> [Model]
    func fetchBatch(offset: Int, limit: Int) async throws -> [Model]
    func delete(model: Model) async throws
}
