//
//  ManagedObjectContainer.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData
import Core

// MARK: - ManagedObjectContainer

/// An object which allows for simple configuration of a managed object container with `async/await` support.
///
/// Example usage:
/// ```swift
/// public struct YourAppCoreDataContainer {
///
///     public static let shared = YourAppCoreDataContainer()
///
///     let container: ManagedObjectContainer
///     private let logger: Logger
///
///     private init() {
///         do {
///             self.container = try ManagedObjectContainer(
///                 modelFileName: "ModelFileName",
///                 in: .module
///             )
///             self.logger = Logger(category: "YourAppCoreDataContainer")
///         } catch {
///             fatalError("Failed to init YourAppCoreDataContainer: \(error)")
///         }
///     }
///
///     init(container: ManagedObjectContainer, logger: Logger) {
///         self.container = container
///         self.logger = logger
///     }
///
///     public func configure() async {
///         do {
///             try await self.container.load()
///         } catch {
///             let message = "Failed to load data store: \(error)"
///             self.logger.error(message)
///             fatalError(message)
///         }
///     }
/// }
/// ```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public class ManagedObjectContainer : CoreDataContainer {
    
    // MARK: - Properties
    
    public let storeName: String
    public let persistentContainer: NSPersistentContainer
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
    /// information see [Apple's documentation for bundling resources with a Swift Package](https://developer.apple.com/documentation/swift_packages/bundling_resources_with_a_swift_package).
    ///
    /// - Parameter modelFileName: File name of the ManagedObjectModel.
    /// - Parameter bundle: Bundle in which the ManagedObjectModel `momd` file exists.
    public convenience init(
        modelFileName: String,
        in bundle: Bundle
    ) throws {
        
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
    public convenience init(
        storeName: String,
        modelUrl: URL
    ) throws {
        
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
    public init(
        storeName: String,
        managedObjectModel: NSManagedObjectModel
    ) {
        self.storeName = storeName
        let persistentContainer = NSPersistentContainer(name: storeName, managedObjectModel: managedObjectModel)
        self.persistentContainer = persistentContainer
        self.mainContext = persistentContainer.viewContext
    }
    
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
    public func configure(fileProtectionType: FileProtectionType) {
        let description = NSPersistentStoreDescription()
        description.setOption(fileProtectionType as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        self.persistentContainer.persistentStoreDescriptions.append(description)
    }
    
    // MARK: - Error
    
    /// Defines errors for creating a managed object container.
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
    
    // MARK: - CoreDataContainer
    
    public func load(completion: @escaping (_ result: Result) -> Void) {
        self.persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public func reset() throws {
        
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
