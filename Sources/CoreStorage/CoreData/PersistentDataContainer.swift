//
//  PersistentDataContainer.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - PersistentDataContainer

/// Represents a `CoreData` persistent store container.
///
/// Example usage for creating a CoreData store from a managed object model:
/// ```swift
/// struct YourCoreDataContainer : PersistentDataContainer {
///
///     static let shared = YourCoreDataContainer() // Recommended to use singleton
///
///     let storeName: String
///     let persistentContainer: NSPersistentContainer
///
///     private init() { // Use a `private` to enfornce the singleton for the data container
///         self.init(
///             storeName: "YourCoreDataModelName",
///             bindle: .model // or .main if in app target
///         )
///     }
///
///     required init(
///         container: NSPersistentContainer
///     ) {
///         self.persistentContainer = container
///     }
/// }
/// ```
public protocol PersistentDataContainer {
    
    /// An instance of NSPersistentContainer includes all objects needed to represent a functioning Core Data stack, and provides
    /// convenience methods and properties for common patterns.
    var persistentContainer: NSPersistentContainer { get }
    
    /// Initializes a CoreData persistent data store.
    ///
    /// Before using the data store be sure to call `coreDataContainer.load(_:)` to instruct
    /// the container to load the persistent stores and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion handler will be called
    /// once for each persistent store that is created. If there is an error in the loading of the persistent stores, the NSError value
    /// will be populated.
    ///
    /// - Parameter container: The core data persistent container.
    init(container: NSPersistentContainer)
}

// MARK: - Extensions

public extension PersistentDataContainer {
    
    // MARK: - Init
    
    /// Initializes a CoreData persistent data store.
    ///
    /// Before using the data store be sure to call `coreDataContainer.load(_:)` to instruct
    /// the container to load the persistent stores and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion handler will be called
    /// once for each persistent store that is created. If there is an error in the loading of the persistent stores, the NSError value
    /// will be populated.
    ///
    /// Note: If you are using a Swift package use `Bundle.module` to access the ManagedObjectModel file. For more
    /// information see [Apple's documentation for bundling resources with a Swift Package](https://developer.apple.com/documentation/swift_packages/bundling_resources_with_a_swift_package).
    ///
    /// - Parameter storeName: The name of the core data model store. Should match the name of the `<storeName>.xcdatamodeld` file.
    /// - Parameter bundle: Bundle in which the ManagedObjectModel `momd` file exists.
    init(
        storeName: String,
        in bundle: Bundle
    ) throws {
        
        guard let modelUrl = bundle.url(forResource: storeName, withExtension: "momd") else {
            throw PersistentModelContainerError.failedToLocateModel(name: storeName, bundle: bundle)
        }
        
        try self.init(storeName: storeName, modelUrl: modelUrl)
    }
    
    /// Initializes a CoreData persistent data store.
    ///
    /// Before using the data store be sure to call `coreDataContainer.load(_:)` to instruct
    /// the container to load the persistent stores and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion handler will be called
    /// once for each persistent store that is created. If there is an error in the loading of the persistent stores, the NSError value
    /// will be populated.
    ///
    /// - Parameter storeName: The name of the core data model store. Should match the name of the `<storeName>.xcdatamodeld` file.
    /// - Parameter modelUrl: URL of the ManagedObjectModel.
    init(
        storeName: String,
        modelUrl: URL
    ) throws {
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            throw PersistentModelContainerError.failedToLoadModel(url: modelUrl)
        }
        
        self.init(storeName: storeName, managedObjectModel: managedObjectModel)
    }
    
    /// Initializes a CoreData persistent data store.
    ///
    /// Before using the data store be sure to call `coreDataContainer.load(_:)` to instruct
    /// the container to load the persistent stores and complete the creation of the Core Data stack.
    ///
    /// Once the completion handler has fired, the stack is fully initialized and is ready for use. The completion handler will be called
    /// once for each persistent store that is created. If there is an error in the loading of the persistent stores, the NSError value
    /// will be populated.
    ///
    /// - Parameter storeName: The name of the core data model store. Should match the name of the `<storeName>.xcdatamodeld` file.
    /// - Parameter managedObjectModel: A programmatic representation of the .xcdatamodeld file describing your objects.
    init(
        storeName: String,
        managedObjectModel: NSManagedObjectModel
    ) {
        let persistentContainer = NSPersistentContainer(
            name: storeName,
            managedObjectModel: managedObjectModel
        )
        self.init(container: persistentContainer)
    }
    
    // MARK: - Loading the Store
    
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
    /// * The store has already been loaded.
    /// Check the error message to determine what the actual problem was.
    private func load(completion: @escaping (_ result: Result) -> Void) {
        self.persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }
    }
    
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
    /// * The store has already been loaded.
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
    
    // MARK: - Configuring File Protection Type
    
    /// Configures the data container's `FileProtectionType`.
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
    @available(macOS, unavailable)
    func configure(
        fileProtectionType: FileProtectionType
    ) {
        let description = NSPersistentStoreDescription()
        description.setOption(
            fileProtectionType as NSObject,
            forKey: NSPersistentStoreFileProtectionKey
        )
        self.persistentContainer.persistentStoreDescriptions.append(description)
    }
    
    // MARK: - Destroy and Reset
    
    /// Resets and destroys the `CoreData` persistent store.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func destroyAndReset() throws {
        
        guard let currentStore = self.persistentContainer.persistentStoreCoordinator.persistentStores.last else {
            return
        }
        
        guard let currentStoreURL = currentStore.url else {
            return
        }
        
        try self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(
            at: currentStoreURL,
            type: .sqlite
        )
        
        try self.persistentContainer.persistentStoreCoordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: currentStoreURL
        )
    }
}
