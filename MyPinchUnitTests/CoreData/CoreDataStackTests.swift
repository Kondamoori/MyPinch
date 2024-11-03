//
//  CoreDataStackTests.swift
//  MyPinchUnitTests
//
//  Created by Kondamoori, S. (Srinivasarao) on 27/10/2024.
//

import XCTest
@testable import MyPinch
import CoreData

class CoreDataStackTests: XCTestCase {
    
    var coreDataStack: CoreDataStack!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataStack = CoreDataStack.shared
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        coreDataStack = nil
    }
    
    func testPersistentContainer() throws {
        XCTAssertNotNil(coreDataStack.persistentContainer)
        XCTAssertNotNil(coreDataStack.mainContext)
    }
    
    func testSaveContext_WithChanges() {
        let context = coreDataStack.mainContext
        let entityName = "GameImageEntity"
        _ = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        XCTAssertTrue(context.hasChanges)
    }
}

extension CoreDataStackTests {
    
    static func makeInMemoryContext() -> NSManagedObjectContext {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: "GamesModel")
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container.viewContext
    }
}
