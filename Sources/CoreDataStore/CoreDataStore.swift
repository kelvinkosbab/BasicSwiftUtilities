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
    
    /// An instance of NSPersistentContainer includes all objects needed to represent a functioning Core Data stack, and provides
    /// convenience methods and properties for common patterns.
    let persistentContainer: NSPersistentContainer
    
    private let logger: Logger
    
    // MARK: - Init
    
    /// Initializes a data store.
    ///
    /// Before using the data store be sure to call `dataStore.load(_ completion:)` to instruct
    /// the container to load the persistent stores and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion handler will be called
    /// once for each persistent store that is created. If there is an error in the loading of the persistent stores, the NSError value
    /// will be populated.
    public init(storeName: String, in bundle: Bundle) {
        
        guard let modelUrl = bundle.url(forResource: storeName, withExtension: "momd") else {
            fatalError("Failed loading Core Data model from bundle for \(storeName)")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("Error initializing mom from: \(modelUrl)")
        }
        
        self.storeName = storeName
        self.logger = Logger(subsystem: "CoreDataStore", category: "DataStore.\(storeName)")
        self.persistentContainer = NSPersistentContainer(name: storeName, managedObjectModel: managedObjectModel)
    }
    
    // MARK: - Persistent Container
    
    /// The persistent container for the application.
    ///
    /// This implementation creates and returns a container, having loaded the store for the
    /// application to it. This property is optional since there are legitimate error conditions that
    /// could cause the creation of the store to fail.
    ///
    /// Once the persistent container has been initialized, you need to execute loadPersistentStores(completionHandler:) to instruct
    /// the container to load the persistent stores and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion handler will be called
    /// once for each persistent store that is created. If there is an error in the loading of the persistent stores, the NSError value
    /// will be populated.
    ///
    /// Typical reasons for an error here include:
    /// * The parent directory does not exist, cannot be created, or disallows writing.
    /// * The persistent store is not accessible, due to permissions or data protection when the device is locked.
    /// * The device is out of space.
    /// * The store could not be migrated to the current model version.
    /// Check the error message to determine what the actual problem was.
    public func load(completion: @escaping (_ result: Result) -> Void) {
        self.persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                self.logger.error("Failed to load persistent container: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }
    }
    
    /// The persistent container for the application.
    ///
    /// This implementation creates and returns a container, having loaded the store for the
    /// application to it. This property is optional since there are legitimate error conditions that
    /// could cause the creation of the store to fail.
    ///
    /// Once the persistent container has been initialized, you need to execute loadPersistentStores(completionHandler:) to instruct
    /// the container to load the persistent stores and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion handler will be called
    /// once for each persistent store that is created. If there is an error in the loading of the persistent stores, the NSError value
    /// will be populated.
    ///
    /// Typical reasons for an error here include:
    /// * The parent directory does not exist, cannot be created, or disallows writing.
    /// * The persistent store is not accessible, due to permissions or data protection when the device is locked.
    /// * The device is out of space.
    /// * The store could not be migrated to the current model version.
    /// Check the error message to determine what the actual problem was.
    @available(iOS 13.0.0, *)
    public func load() async throws -> Result {
        await withCheckedContinuation { continuation in
            self.load() { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    // MARK: - Managed Object Context
    
    /// The managed object context associated with the main queue of the persistent container.
    public lazy var mainContext: NSManagedObjectContext = self.persistentContainer.viewContext
    
    /// Saves any changes on the main data store context.
    ///
    /// If this function throws you should handle the error appropriately. You should NOT use `fatalError()` in a shipping
    /// application, although it may be useful during development.
    public func saveMainContext() throws {
        
        guard self.mainContext.hasChanges else {
            return
        }
        
        do {
            try self.mainContext.save()
        } catch {
            self.logger.error("Failed to save main context: \(error.localizedDescription)")
            throw error
        }
    }
}
