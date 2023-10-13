//
//  ManagedObjectStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ManagedObjectStore

/// A data store which provides utilities for fetching objects of a certain data type. Data types in CoreData are
/// mapped to a `struct` data type for thread safe operations and allow easy access for consumers of the
/// data store API.
///
/// In your app with this data store defined you can easily perform fetch, create, update, or delete objects
/// without the need for any deep knowledge of how `CoreData` works.
///
/// This object also provides support for classes that are a sub-class of a parent `CoreData` object. Similar
/// to parent objects these sub-class objects can be created, queried, updated, or deleted.
///
/// Example usage:
/// ```swift
///
/// public enum StoreOperationType {
///     case mainQueue
///     case privateQueue
/// }
///
/// public struct SomeObjectDataStore : ManagedObjectStore {
///
///     public typealias ObjectType = SomeObjectStructType
///
///     public let context: NSManagedObjectContext
///
///     public init(context: NSManagedObjectContext) {
///         self.context = context
///     }
/// }
///
/// // Example usage of this data store to fetch an object with a unique ID of 'objectID'.
///
/// let dataContainer = YourAppDataContainer()
/// let store = OneObjectDataStore(context: dataContainer.context)
/// let object = store.fetchOne(id: "objectID")
/// ```
///
/// **Utilizing CoreData main and private data queues**
///
/// Core Data is designed to work in a multithreaded environment. However, not every object under the
/// Core Data framework is thread safe. To use Core Data in a multithreaded environment, ensure that:
///
/// - Managed object contexts are bound to the thread (queue) that they are associated with upon initialization.
/// - Managed objects retrieved from a context are bound to the same queue that the context is bound to.
///
/// To utilize the private queue you can use something like this when creating your object data store:
/// ```swift
/// let dataContainer = YourAppDataContainer()
/// let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
/// context.parent = dataContainer.context
/// let store = OneObjectDataStore(context: privateContext)
/// ```
///
/// For more information see [Apple's documentation](https://developer.apple.com/documentation/coredata/using_core_data_in_the_background).
@available(iOS 13.0.0, *)
public protocol ManagedObjectStore where ObjectType.ManagedObject.StructType == ObjectType {
    
    associatedtype ObjectType: ManagedObjectAssociated
    typealias ManagedObject = ObjectType.ManagedObject
    
    var context: NSManagedObjectContext { get }
    
    /// Saves any changes on the context.
    ///
    /// If this function throws you should handle the error appropriately. You should NOT use `fatalError()` in a shipping
    /// application, although it may be useful during development.
    ///
    /// - Throws if there is an error during the operation.
    func saveChanges() throws
}

@available(iOS 13.0.0, *)
public extension ManagedObjectStore {
    
    /// Saves any changes on the context.
    ///
    /// If this function throws you should handle the error appropriately. You should NOT use `fatalError()` in a shipping
    /// application, although it may be useful during development.
    ///
    /// - Throws if there is an error during the operation.
    func saveChanges() throws {
        
        guard self.context.hasChanges else {
            return
        }
        
        try self.context.save()
    }
    
    // MARK: - Create or Update
    
    func createOrUpdate(_ object: ObjectType) throws {
        var cdObject = try ManagedObject.fetchOne(id: object.identifier, context: self.context) ?? ManagedObject.create(context: self.context)
        cdObject.structValue = object
        try self.saveChanges()
    }
}
