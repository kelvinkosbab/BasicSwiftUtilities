//
//  CoreDataPersistentContainer.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - CoreDataPersistentContainer

public protocol CoreDataPersistentContainer: AnyObject {

    /// The main queue’s managed object context.
    ///
    /// This property contains a reference to the `NSManagedObjectContext` that is created and owned
    /// by the persistent container which is associated with the main queue of the application. This context is
    /// created automatically as part of the initialization of the persistent container.
    ///
    /// This context is associated directly with the `NSPersistentStoreCoordinator` and is non-generational by default.
    var viewContext: NSManagedObjectContext { get }

    /// The descriptions of the container’s persistent stores.
    ///
    /// If you want to override the type (or types) of persistent store(s) used by the persistent container, you can set this
    /// property with an array of `NSPersistentStoreDescription` objects.
    ///
    /// If you will be configuring custom persistent store descriptions, you must set this property before calling
    /// `loadPersistentStores(completionHandler:)`.
    var persistentStoreDescriptions: [NSPersistentStoreDescription] { get set }

    /// Loads the persistent container for the application.
    ///
    /// This implementation creates and returns a container, having loaded the store for the
    /// application to it. This property is optional since there are legitimate error conditions that
    /// could cause the creation of the store to fail.
    ///
    /// Once the persistent container has been initialized, you need to execute
    /// `loadPersistentStores(completionHandler:)` to instruct the container to load the persistent stores
    /// and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion
    /// handler will be called once for each persistent store that is created. If there is an error in the
    /// loading of the persistent stores, the `NSError` value will be populated.
    ///
    /// Typical reasons for an error here include:
    /// * The parent directory does not exist, cannot be created, or disallows writing.
    /// * The persistent store is not accessible, due to permissions or data protection when the device is locked.
    /// * The device is out of space.
    /// * The store could not be migrated to the current model version.
    /// * The store has already been loaded.
    /// Check the error message to determine what the actual problem was.
    func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void)
}

// MARK: - NSPersistentContainer & CoreDataPersistentContainer

extension NSPersistentContainer: CoreDataPersistentContainer {}
