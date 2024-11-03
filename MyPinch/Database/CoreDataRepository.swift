//
//  CoreDataRepository.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 26/10/2024.
//

import Foundation
import CoreData
import Combine

/// Error to track PersistenceDataStore errors.
enum PersistenceDataStoreError: Error {
    case failedToReadContext
}

/// Repository which will make use of core data internally.
final class CoreDataRepository<Model: Persistable>: Repository where Model.Entity: NSManagedObject {
    
    // MARK: - Private properties
    
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
    }
    
    // MARK: - Internal functions
    
    /// Function to save model into database
    /// - Parameter model: any Model which confirms to Persistable
    func save(model: Model) async throws {
        try await context.perform { [weak self] in
            guard let self else { throw PersistenceDataStoreError.failedToReadContext }
            if let existingEntity = try checkAndReturnIfEntityExist(entity: model) {
                let _ = model.updateEntity(existingEntity, context: self.context)
            } else {
                let _ = model.toEntity(in: self.context)
            }
            
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }
    
    /// Function to save model into database
    /// - Returns: array of models any which confirms to Persistable
    func fetchAll() async throws -> [Model] {
        try await context.perform { [weak self] in
            guard let self else { throw PersistenceDataStoreError.failedToReadContext }
            let fetchRequest = NSFetchRequest<Model.Entity>(entityName: String(describing: Model.Entity.self))
            let entities = try self.context.fetch(fetchRequest)
            return entities.map { Model.fromEntity($0)}
        }
    }
    
    /// Function to fetch records from database with predicate
    /// - Parameter predicate: predicate to fetch
    /// - Returns: returns array objects form database which satisfy the predicate.
    func fetchAll(predicate: NSPredicate? = nil) async throws -> [Model] {
        try await context.perform { [weak self] in
            guard let self else { throw PersistenceDataStoreError.failedToReadContext }
            let fetchRequest = NSFetchRequest<Model.Entity>(entityName: String(describing: Model.Entity.self))
            fetchRequest.predicate = predicate
            let entities = try self.context.fetch(fetchRequest)
            return entities.map { Model.fromEntity($0)}
        }
    }
    
    /// Function to fetch records with offset, this is useful when you integrate a list which supports pagination.
    /// - Parameters:
    ///   - offset: offset from which index you want fetch from coredata.
    ///   - limit: limit
    /// - Returns: returns array of records which are fetch by fetch request created by offset & limit.
    func fetchBatch(offset: Int, limit: Int) async throws -> [Model] {
        try await context.perform { [weak self] in
            guard let self else { throw PersistenceDataStoreError.failedToReadContext }
            let fetchRequest = NSFetchRequest<Model.Entity>(entityName: String(describing: Model.Entity.self))
            let count = try self.context.count(for: fetchRequest)
            fetchRequest.fetchLimit = limit
            fetchRequest.fetchOffset = offset
            if offset > count {
                return []
            }
            let entities = try self.context.fetch(fetchRequest)
            return entities.map { Model.fromEntity($0)}
        }
    }
    
    /// Function to delete record from coredata.
    /// - Parameter model: model to delete.
    func delete(model: Model) async throws {
        try await context.perform { [weak self] in
            guard let self else { throw PersistenceDataStoreError.failedToReadContext }
            
            let entity = model.toEntity(in: self.context)
            self.context.delete(entity)
            if self.context.hasChanges {
                try self.context.save()
            }
            
        }
    }
    
    /// Function to save array of records to database. It also check for duplicates, if record already exist it will update the existing record.
    /// - Parameter models: array of records which needs to be stored.
    func saveAll(models: [Model]) async throws {
        try await context.perform { [weak self] in
            guard let self else { throw PersistenceDataStoreError.failedToReadContext }
            
            for model in models {
                if let existingEntity = try checkAndReturnIfEntityExist(entity: model) {
                    let _ = model.updateEntity(existingEntity, context: self.context)
                } else {
                    let _ = model.toEntity(in: self.context)
                }
            }
            
            if context.hasChanges {
                try self.context.save()
            }
        }
    }
    
    /// Function to check duplicate records in database.
    /// - Parameter entity: entity need to be checked.
    /// - Returns: returns entity, if record already exist.
    private func checkAndReturnIfEntityExist(entity: Model) throws -> Model.Entity? {
        let fetchRequest = NSFetchRequest<Model.Entity>(entityName: String(describing: Model.Entity.self))
        let predicate = NSPredicate(format: "id == %ld", entity.primaryKey)
        fetchRequest.predicate = predicate
        return try self.context.fetch(fetchRequest).first
    }
}
