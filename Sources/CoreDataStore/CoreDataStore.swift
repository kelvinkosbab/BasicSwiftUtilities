//
//  CoreDataStore.swift
//
//  Created by Kelvin Kosbab on 10/11/21.
//

import CoreData
import Core

// MARK: - CoreDataStore

public class CoreDataStore {
    
    // MARK: - Properties
    
    /// The name of the core data model store. Should match the name of the *.xcdatamodeld file.
    let storeName: String
    
    /// An instance of NSPersistentContainer includes all objects needed to represent a functioning Core Data stack, and provides convenience methods and properties for common patterns.
    let persistentContainer: NSPersistentContainer
    
    private let logger: Logger
    
    // MARK: - Init
    
    /// This implementation creates and returns a container, having loaded the store for the
    /// application to it. This property is optional since there are legitimate error conditions that
    /// could cause the creation of the store to fail.
    ///
    /// Typical reasons for an error here include:
    /// * The parent directory does not exist, cannot be created, or disallows writing.
    /// * The persistent store is not accessible, due to permissions or data protection when the device is locked.
    /// * The device is out of space.
    /// * The store could not be migrated to the current model version.
    /// Check the error message to determine what the actual problem was.
    public init(storeName: String, in bundle: Bundle) {
        
        self.storeName = storeName
        
        guard let modelUrl = Bundle(for: Self.self).url(forResource: self.storeName, withExtension: "momd") else {
            fatalError("Failed loading Core Data model from bundle for \(storeName)")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("Error initializing mom from: \(modelUrl)")
        }
        
        self.logger = Logger(subsystem: "CoreDataStore", category: "DataStore.\(storeName)")
        self.persistentContainer = NSPersistentContainer(name: storeName, managedObjectModel: managedObjectModel)
        self.loadPersistentContainer(self.persistentContainer)
    }
    
    // MARK: - Persistent Container
    
    /// The persistent container for the application.
    ///
    /// This implementation creates and returns a container, having loaded the store for the
    /// application to it. This property is optional since there are legitimate error conditions that
    /// could cause the creation of the store to fail.
    private func loadPersistentContainer(_ container: NSPersistentContainer) {
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. Youshould not use this function in a shipping application, although it may be useful during development.
                self.logger.error("Unresolved error for container \(self.storeName): \(error), \(error.userInfo)")
                fatalError("Unresolved error for container \(self.storeName): \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Managed Object Context
    
    /// The managed object context associated with the main queue.
    public lazy var mainContext: NSManagedObjectContext = self.persistentContainer.viewContext
    
    public func saveMainContext() {
        
        guard self.mainContext.hasChanges else {
            return
        }
        
        do {
            try mainContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            self.logger.error("Unresolved error \(nserror), \(nserror.userInfo)")
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    public lazy var dataContext: NSManagedObjectContext = {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = self.mainContext
        return privateContext
    }()
    
    public func saveDataContext() {
        do {
            try self.dataContext.save()
            self.mainContext.performAndWait { [weak self] in
                self?.saveMainContext()
            }
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            self.logger.error("Unresolved dataContext error \(nserror), \(nserror.userInfo)")
            fatalError("Unresolved dataContext error \(nserror), \(nserror.userInfo)")
        }
    }
}
