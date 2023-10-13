//
//  CoreDataContainer.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - CoreDataContainer

/// Represents a `CoreData` store container.
public protocol CoreDataContainer {
    
    /// The name of the core data model store. Should match the name of the `<storeName>.xcdatamodeld` file.
    var storeName: String { get }
    
    /// An instance of NSPersistentContainer includes all objects needed to represent a functioning Core Data stack, and provides
    /// convenience methods and properties for common patterns.
    var persistentContainer: NSPersistentContainer { get }
    
    /// The main queue’s managed object context.
    ///
    /// This property contains a reference to the `NSManagedObjectContext` that is created and owned by the persistent container
    /// which is associated with the main queue of the application. This context is created automatically as part of the initialization
    /// of the persistent container.
    ///
    /// This context is associated directly with the `NSPersistentStoreCoordinator` and is non-generational by default
    var mainContext: NSManagedObjectContext { get }
    
    /// Loads the persistent container for the application.
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
    func load(completion: @escaping (_ result: Result) -> Void)
    
    /// Resets and destroys the `CoreData` persistent store.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func reset() throws
}

public extension CoreDataContainer {
    
    /// Asyncronously loads the persistent container for the application.
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
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func load() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.load() { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
