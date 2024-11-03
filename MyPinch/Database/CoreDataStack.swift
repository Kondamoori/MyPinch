//
//  CoreDataStack.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 26/10/2024.
//

import Foundation
import CoreData

/// Type used for offline store.
final class CoreDataStack {
    
    // MARK: - Shared instance
    
    static let shared = CoreDataStack()
    
    // MARK: - Internal properties
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    // MARK: - Init - We made it private to avoid initialising this from outside.
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GamesModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()
    
    // MARK: - Internal functions
    
    func saveContext() {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
