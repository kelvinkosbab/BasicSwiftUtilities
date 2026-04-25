//
//  ObjectStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

public import CoreData

// MARK: - ObjectStore

/// A type-safe wrapper around a CoreData entity that bridges between Swift `struct`
/// values and `NSManagedObject` instances.
///
/// `ObjectStore` provides CRUD operations for a single entity type, with both synchronous
/// (`@MainActor` `viewContext`) and asynchronous (background context) variants of every
/// fetch and mutation. Synchronous methods must be called on the main actor; async
/// methods perform their work on a background context.
///
/// To define a store, conform to this protocol with an `Object` type that conforms to
/// ``AssociatedWithPersistentObject``:
///
/// ```swift
/// struct UserStore: ObjectStore {
///     typealias Object = User  // a struct conforming to AssociatedWithPersistentObject
///     let container: PersistentDataContainer
/// }
/// ```
///
/// ## Topics
///
/// ### Required
///
/// - ``container``
///
/// ### Creating and Updating
///
/// - ``createOrUpdate(_:)-(Object)``
/// - ``createOrUpdate(_:)-(Object)-async``
///
/// ### Fetching
///
/// - ``newFetchRequest(predicate:sortDescriptors:)``
/// - ``fetch(predicate:sortDescriptors:)-(_,_)``
/// - ``fetch(predicate:sortDescriptors:)-(_,_)-async``
/// - ``fetchOne(id:)-(String)``
/// - ``fetchOne(id:)-(String)-async``
/// - ``fetchMany(in:)-([String])``
/// - ``fetchMany(in:)-([String])-async``
/// - ``fetchMany(notIn:)-([String])``
/// - ``fetchMany(notIn:)-([String])-async``
/// - ``fetchAll(sortDescriptors:)-([NSSortDescriptor]?)``
/// - ``fetchAll(sortDescriptors:)-([NSSortDescriptor]?)-async``
///
/// ### Deletion
///
/// - ``delete(predicate:)-(NSPredicate?)``
/// - ``delete(predicate:)-(NSPredicate?)-async``
/// - ``deleteOne(id:)-(String)``
/// - ``deleteOne(id:)-(String)-async``
/// - ``deleteMany(in:)-([String])``
/// - ``deleteMany(in:)-([String])-async``
/// - ``deleteMany(notIn:)-([String])``
/// - ``deleteMany(notIn:)-([String])-async``
/// - ``deleteAll()``
/// - ``deleteAll()-async``
public protocol ObjectStore: Sendable where Object.PersistentObject.Object == Object {

    /// The Swift `struct` type associated with the persisted `NSManagedObject`.
    associatedtype Object: AssociatedWithPersistentObject & Sendable

    /// The `NSManagedObject` subclass that is persisted in the CoreData store.
    typealias PersistedObject = Object.PersistentObject

    /// The persistent data container backing this store.
    var container: PersistentDataContainer { get }
}

internal extension ObjectStore {

    // MARK: - Save

    var context: NSManagedObjectContext {
        self.container.coreDataContainer.viewContext
    }

    /// Saves any changes on the context.
    ///
    /// - Throws: An `NSError` from CoreData if the save fails.
    func saveChanges() throws {

        guard self.context.hasChanges else {
            return
        }

        try self.context.save()
    }

    // MARK: - Entity Name

    var entityName: String {
        String(describing: PersistedObject.self)
    }

    // MARK: - Create

    func create() throws -> Object.PersistentObject {
        guard let object = NSEntityDescription.insertNewObject(
            forEntityName: self.entityName,
            into: self.context
        ) as? Object.PersistentObject else {
            throw ObjectStoreError.unableToCreate(entityName: self.entityName)
        }

        return object
    }
}

// MARK: - Create or Update

public extension ObjectStore {

    /// Inserts a new managed object for this struct, or updates the existing one if its
    /// identifier matches an existing record.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Parameter object: The struct value to persist.
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func createOrUpdate(_ object: Object) throws {
        let predicate = NSPredicate(id: object.identifier)
        let request = self.newFetchRequest(
            predicate: predicate,
            sortDescriptors: nil
        )
        var persistentObject = try self.context.fetch(request).first ?? self.create()
        persistentObject.structValue = object
        try self.context.save()
    }

    /// Asynchronously inserts a new managed object for this struct, or updates the existing
    /// one if its identifier matches an existing record.
    ///
    /// The fetch and save are performed on the context's queue.
    ///
    /// - Parameter object: The struct value to persist.
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func createOrUpdate(_ object: Object) async throws {
        return try await self.context.perform {
            return try self.createOrUpdate(object)
        }
    }
}

// MARK: - Fetching

public extension ObjectStore {

    // MARK: - Fetch Request

    /// Builds a new `NSFetchRequest` configured for this store's entity.
    ///
    /// `returnsObjectsAsFaults` is set to `false` so all attributes are populated immediately.
    ///
    /// - Parameter predicate: An optional `NSPredicate` to filter results.
    /// - Parameter sortDescriptors: An optional list of sort descriptors to order results.
    /// - Returns: A configured `NSFetchRequest` for this store's `PersistedObject`.
    func newFetchRequest(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> NSFetchRequest<PersistedObject> {
        let fetchRequest = NSFetchRequest<PersistedObject>(
            entityName: self.entityName
        )
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        return fetchRequest
    }

    // MARK: - Fetch by NSPredicate

    /// Synchronously fetches all struct values matching the given predicate.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Parameter predicate: An optional `NSPredicate` to filter results. Pass `nil` to fetch all.
    /// - Parameter sortDescriptors: An optional list of sort descriptors to order results.
    /// - Returns: An array of struct values matching the predicate.
    /// - Throws: An `NSError` from CoreData if the fetch fails.
    func fetch(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [Object.PersistentObject.Object] {
        let request = self.newFetchRequest(
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        return try self.context.fetch(request).structValues
    }

    /// Asynchronously fetches all struct values matching the given predicate.
    ///
    /// - Parameter predicate: An optional `NSPredicate` to filter results. Pass `nil` to fetch all.
    /// - Parameter sortDescriptors: An optional list of sort descriptors to order results.
    /// - Returns: An array of struct values matching the predicate.
    /// - Throws: An `NSError` from CoreData if the fetch fails.
    func fetch(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) async throws -> [Object.PersistentObject.Object] {
        nonisolated(unsafe) let unsafePredicate = predicate
        nonisolated(unsafe) let unsafeSortDescriptors = sortDescriptors
        return try await self.context.perform {
            return try self.fetch(
                predicate: unsafePredicate,
                sortDescriptors: unsafeSortDescriptors
            )
        }
    }

    // MARK: - Fetch One

    /// Synchronously fetches the single struct value with the given identifier.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Parameter id: The unique identifier of the object to fetch.
    /// - Returns: The matching struct value, or `nil` if no record exists with that identifier.
    /// - Throws: An `NSError` from CoreData if the fetch fails.
    func fetchOne(
        id: String
    ) throws -> Object.PersistentObject.Object? {
        let predicate = NSPredicate(id: id)
        return try self.fetch(predicate: predicate).first
    }

    /// Asynchronously fetches the single struct value with the given identifier.
    ///
    /// - Parameter id: The unique identifier of the object to fetch.
    /// - Returns: The matching struct value, or `nil` if no record exists with that identifier.
    /// - Throws: An `NSError` from CoreData if the fetch fails.
    func fetchOne(
        id: String
    ) async throws -> Object.PersistentObject.Object? {
        let predicate = NSPredicate(id: id)
        return try await self.fetch(
            predicate: predicate
        ).first
    }

    // MARK: - Fetch Many

    /// Synchronously fetches all struct values whose identifier is included in the given list.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Parameter ids: The unique identifiers of the objects to fetch.
    /// - Returns: An array of struct values matching any of the given identifiers.
    /// - Throws: An `NSError` from CoreData if the fetch fails.
    func fetchMany(
        in ids: [String]
    ) throws -> [Object.PersistentObject.Object] {
        let predicate = NSPredicate(ids: ids)
        return try self.fetch(predicate: predicate)
    }

    /// Asynchronously fetches all struct values whose identifier is included in the given list.
    ///
    /// - Parameter ids: The unique identifiers of the objects to fetch.
    /// - Returns: An array of struct values matching any of the given identifiers.
    /// - Throws: An `NSError` from CoreData if the fetch fails.
    func fetchMany(
        in ids: [String]
    ) async throws -> [Object.PersistentObject.Object] {
        let predicate = NSPredicate(ids: ids)
        return try await self.fetch(
            predicate: predicate
        )
    }

    /// Synchronously fetches all struct values whose identifier is NOT included in the given list.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Parameter ids: The identifiers to exclude from the result.
    /// - Returns: An array of struct values whose identifier does not appear in `ids`.
    /// - Throws: An `NSError` from CoreData if the fetch fails.
    func fetchMany(
        notIn ids: [String]
    ) throws -> [Object.PersistentObject.Object] {
        let predicate = NSPredicate(notIn: ids)
        return try self.fetch(
            predicate: predicate
        )
    }

    /// Asynchronously fetches all struct values whose identifier is NOT included in the given list.
    ///
    /// - Parameter ids: The identifiers to exclude from the result.
    /// - Returns: An array of struct values whose identifier does not appear in `ids`.
    /// - Throws: An `NSError` from CoreData if the fetch fails.
    func fetchMany(
        notIn ids: [String]
    ) async throws -> [Object.PersistentObject.Object] {
        let predicate = NSPredicate(notIn: ids)
        return try await self.fetch(
            predicate: predicate
        )
    }

    // MARK: - Fetch All

    /// Synchronously fetches every struct value of this store's entity type.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Parameter sortDescriptors: An optional list of sort descriptors to order results.
    /// - Returns: All struct values for this entity type.
    /// - Throws: An `NSError` from CoreData if the fetch fails.
    func fetchAll(
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [Object.PersistentObject.Object] {
        let request = self.newFetchRequest(sortDescriptors: sortDescriptors)
        request.returnsObjectsAsFaults = false
        return try self.fetch(
            predicate: nil,
            sortDescriptors: sortDescriptors
        )
    }

    /// Asynchronously fetches every struct value of this store's entity type.
    ///
    /// - Parameter sortDescriptors: An optional list of sort descriptors to order results.
    /// - Returns: All struct values for this entity type.
    /// - Throws: An `NSError` from CoreData if the fetch fails.
    func fetchAll(
        sortDescriptors: [NSSortDescriptor]? = nil
    ) async throws -> [Object.PersistentObject.Object] {
        let request = self.newFetchRequest(sortDescriptors: sortDescriptors)
        request.returnsObjectsAsFaults = false
        return try await self.fetch(
            predicate: nil,
            sortDescriptors: sortDescriptors
        )
    }

}

// MARK: - Deletion

public extension ObjectStore {

    // MARK: - Deletion by NSPredicate

    /// Synchronously deletes every managed object matching the given predicate.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Parameter predicate: An optional `NSPredicate` selecting which objects to delete.
    ///   Pass `nil` to delete all objects of this entity type.
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func delete(
        predicate: NSPredicate?
    ) throws {
        let request = self.newFetchRequest(predicate: predicate)
        for object in try self.context.fetch(request) {
            self.context.delete(object)
        }
        try self.saveChanges()
    }

    /// Asynchronously deletes every managed object matching the given predicate.
    ///
    /// - Parameter predicate: An optional `NSPredicate` selecting which objects to delete.
    ///   Pass `nil` to delete all objects of this entity type.
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func delete(
        predicate: NSPredicate?
    ) async throws {
        nonisolated(unsafe) let unsafePredicate = predicate
        return try await self.context.perform {
            let request = self.newFetchRequest(predicate: unsafePredicate)
            for object in try self.context.fetch(request) {
                self.context.delete(object)
            }
            try self.saveChanges()
        }
    }

    // MARK: - Delete One

    /// Synchronously deletes the object with the given identifier.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Parameter id: The unique identifier of the object to delete.
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func deleteOne(id: String) throws {
        let predicate = NSPredicate(id: id)
        try self.delete(predicate: predicate)
    }

    /// Asynchronously deletes the object with the given identifier.
    ///
    /// - Parameter id: The unique identifier of the object to delete.
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func deleteOne(id: String) async throws {
        let predicate = NSPredicate(id: id)
        try await self.delete(predicate: predicate)
    }

    // MARK: - Delete Many

    /// Synchronously deletes all objects whose identifier is included in the given list.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Parameter ids: The unique identifiers of the objects to delete.
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func deleteMany(in ids: [String]) throws {
        let predicate = NSPredicate(ids: ids)
        try self.delete(predicate: predicate)
    }

    /// Asynchronously deletes all objects whose identifier is included in the given list.
    ///
    /// - Parameter ids: The unique identifiers of the objects to delete.
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func deleteMany(in ids: [String]) async throws {
        let predicate = NSPredicate(ids: ids)
        try await self.delete(predicate: predicate)
    }

    /// Synchronously deletes all objects whose identifier is NOT included in the given list.
    ///
    /// Useful for removing stale records after a sync, keeping only the records present in
    /// `ids`.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Parameter ids: The identifiers to exclude from deletion.
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func deleteMany(notIn ids: [String]) throws {
        let predicate = NSPredicate(notIn: ids)
        try self.delete(predicate: predicate)
    }

    /// Asynchronously deletes all objects whose identifier is NOT included in the given list.
    ///
    /// - Parameter ids: The identifiers to exclude from deletion.
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func deleteMany(notIn ids: [String]) async throws {
        let predicate = NSPredicate(notIn: ids)
        try await self.delete(predicate: predicate)
    }

    // MARK: - Delete All

    /// Synchronously deletes every object of this store's entity type.
    ///
    /// Must be called on the main actor since it operates on `viewContext`.
    ///
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func deleteAll() throws {
        try self.delete(predicate: nil)
    }

    /// Asynchronously deletes every object of this store's entity type.
    ///
    /// - Throws: An `NSError` from CoreData if the fetch or save fails.
    func deleteAll() async throws {
        try await self.delete(predicate: nil)
    }
}
