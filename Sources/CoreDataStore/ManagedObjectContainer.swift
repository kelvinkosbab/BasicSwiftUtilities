//
//  CoreDataContainer.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData
import Core

// MARK: - CoreDataContainer

public class ManagedObjectContainer : StoreContainer {
    
    // MARK: - Properties
    
    /// The name of the core data model store. Should match the name of the *.xcdatamodeld file.
    public let storeName: String
    
    /// An instance of NSPersistentContainer includes all objects needed to represent a functioning Core Data stack, and provides
    /// convenience methods and properties for common patterns.
    public let persistentContainer: NSPersistentContainer
    
    /// The main queue’s managed object context.
    ///
    /// This property contains a reference to the `NSManagedObjectContext` that is created and owned by the persistent container
    /// which is associated with the main queue of the application. This context is created automatically as part of the initialization
    /// of the persistent container.
    ///
    /// This context is associated directly with the `NSPersistentStoreCoordinator` and is non-generational by default
    public let mainContext: NSManagedObjectContext
    
    // MARK: - Init
    
    /// Initializes a data store.
    ///
    /// Before using the data store be sure to call `dataStore.load(_ completion:)` to instruct
    /// the container to load the persistent stores and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion handler will be called
    /// once for each persistent store that is created. If there is an error in the loading of the persistent stores, the NSError value
    /// will be populated.
    ///
    /// Note: If you are using a Swift package use `Bundle.module` to access the ManagedObjectModel file. For more
    /// information see https://developer.apple.com/documentation/swift_packages/bundling_resources_with_a_swift_package.
    ///
    /// - Parameter modelFileName: File name of the ManagedObjectModel.
    /// - Parameter bundle: Bundle in which the ManagedObjectModel `momd` file exists.
    public convenience init(modelFileName: String, in bundle: Bundle) throws {
        
        guard let modelUrl = bundle.url(forResource: modelFileName, withExtension: "momd") else {
            throw Error.failedToGetModelUrl(modelFileName: modelFileName)
        }
        
        try self.init(storeName: modelFileName, modelUrl: modelUrl)
    }
    
    /// Initializes a data store.
    ///
    /// Before using the data store be sure to call `dataStore.load(_ completion:)` to instruct
    /// the container to load the persistent stores and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion handler will be called
    /// once for each persistent store that is created. If there is an error in the loading of the persistent stores, the NSError value
    /// will be populated.
    ///
    /// - Parameter storeName: File name of the ManagedObjectModel.
    /// - Parameter modelUrl: URL of the ManagedObjectModel.
    public convenience init(storeName: String, modelUrl: URL) throws {
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            throw Error.failedToCreateModel(url: modelUrl)
        }
        
        self.init(storeName: storeName, managedObjectModel: managedObjectModel)
    }
    
    /// Initializes a data store.
    ///
    /// Before using the data store be sure to call `dataStore.load(_ completion:)` to instruct
    /// the container to load the persistent stores and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion handler will be called
    /// once for each persistent store that is created. If there is an error in the loading of the persistent stores, the NSError value
    /// will be populated.
    ///
    /// - Parameter storeName: File name of the ManagedObjectModel.
    /// - Parameter managedObjectModel: A programmatic representation of the .xcdatamodeld file describing your objects.
    public init(storeName: String, managedObjectModel: NSManagedObjectModel) {
        self.storeName = storeName
        let persistentContainer = NSPersistentContainer(name: storeName, managedObjectModel: managedObjectModel)
        self.persistentContainer = persistentContainer
        self.mainContext = persistentContainer.viewContext
    }
    
    /// Configures the persistent container's `FileProtectionType`.
    ///
    /// Options:
    /// - `complete`: The file is stored in an encrypted format on disk and cannot be read from or written to while the device is
    /// locked or booting.
    /// - `completeUnlessOpen`: The file is stored in an encrypted format on disk after it is closed. Files with this type of
    /// protection can be created while the device is locked, but once closed, cannot be opened again until the device is unlocked.
    /// If the file is opened when unlocked, you may continue to access the file normally, even if the user locks the device. There is a
    /// small performance penalty when the file is created and opened, though not when being written to or read from. This can be
    /// mitigated by changing the file protection to complete when the device is unlocked.
    /// - `completeUntilFirstUserAuthentication`: The file is stored in an encrypted format on disk and cannot be
    /// accessed until after the device has booted. After the user unlocks the device for the first time, your app can access the file
    /// and continue to access it even if the user subsequently locks the device.
    /// - `none`: The file has no special protections associated with it. A file with this type of protection can be read from or written to at any time.
    public func configure(fileProtectionType: FileProtectionType) {
        let description = NSPersistentStoreDescription()
        description.setOption(fileProtectionType as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        self.persistentContainer.persistentStoreDescriptions.append(description)
    }
    
    // MARK: - Error
    
    public enum Error : Swift.Error, LocalizedError {
        case failedToGetModelUrl(modelFileName: String)
        case failedToCreateModel(url: URL)
        
        public var errorDescription: String? {
            switch self {
            case .failedToGetModelUrl(modelFileName: let modelFileName):
                return "Failed to get managed object URL from bundle: \(modelFileName).momd"
            case .failedToCreateModel(url: let url):
                return "Failed to get NSManagedObjectModel from url: \(url)"
            }
        }
    }
    
    // MARK: - Persistent Container
    
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
    public func load(completion: @escaping (_ result: Result) -> Void) {
        self.persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }
    }
    
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
    @available(iOS 13.0.0, *)
    public func load() async throws {
        try await withCheckedThrowingVoidContinuation { continuation in
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
    
    /// Resets and destroys the CoreData persistent store.
    @available(iOS 15.0, *)
    public func reset() throws {
        
        guard let currentStore = self.persistentContainer.persistentStoreCoordinator.persistentStores.last else {
            return
        }
        
        guard let currentStoreURL = currentStore.url else {
            return
        }
        
        try self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: currentStoreURL, type: .sqlite)
        try self.persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: currentStoreURL)
    }
    
    // MARK: - Managed Object Context
    
    /// Saves any changes on the main data store context.
    ///
    /// If this function throws you should handle the error appropriately. You should NOT use `fatalError()` in a shipping
    /// application, although it may be useful during development.
    public func saveMainContext() throws {
        
        guard self.mainContext.hasChanges else {
            return
        }
        
        try self.mainContext.save()
    }
}
