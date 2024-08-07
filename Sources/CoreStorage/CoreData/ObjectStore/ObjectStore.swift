//
//  ObjectStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ObjectStore

@available(iOS 13.0.0, *)
public protocol ObjectStore where Object.PersistentObject.Object == Object {

    /// Type of the `struct` object that can is associated with the persisted `NSManagedObject` type.
    associatedtype Object: AssociatedWithPersistentObject

    /// Type of the `NSObject.NSManagedObject` that is persisted in the `CoreData` persistent model store.
    typealias PersistedObject = Object.PersistentObject

    /// Reference to the persistent data container for this object's CoreData entity.
    var container: PersistentDataContainer { get }
}

@available(iOS 13.0.0, *)
internal extension ObjectStore {

    // MARK: - Save

    var context: NSManagedObjectContext {
        self.container.coreDataContainer.viewContext
    }

    /// Saves any changes on the context.
    ///
    /// - Throws if there is an error during the operation.
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

@available(iOS 13.0.0, *)
public extension ObjectStore {

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

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func createOrUpdate(_ object: Object) async throws {
        return try await self.context.perform {
            return try self.createOrUpdate(object)
        }
    }
}

// MARK: - Fetching

@available(iOS 13.0.0, *)
public extension ObjectStore {

    // MARK: - Fetch Request

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

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetch(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) async throws -> [Object.PersistentObject.Object] {
        return try await self.context.perform {
            return try self.fetch(
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
        }
    }

    // MARK: - Fetch One

    func fetchOne(
        id: String
    ) throws -> Object.PersistentObject.Object? {
        let predicate = NSPredicate(id: id)
        return try self.fetch(predicate: predicate).first
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchOne(
        id: String
    ) async throws -> Object.PersistentObject.Object? {
        let predicate = NSPredicate(id: id)
        return try await self.fetch(
            predicate: predicate
        ).first
    }

    // MARK: - Fetch Many

    func fetchMany(
        in ids: [String]
    ) throws -> [Object.PersistentObject.Object] {
        let predicate = NSPredicate(ids: ids)
        return try self.fetch(predicate: predicate)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(
        in ids: [String]
    ) async throws -> [Object.PersistentObject.Object] {
        let predicate = NSPredicate(ids: ids)
        return try await self.fetch(
            predicate: predicate
        )
    }

    func fetchMany(
        notIn ids: [String]
    ) throws -> [Object.PersistentObject.Object] {
        let predicate = NSPredicate(notIn: ids)
        return try self.fetch(
            predicate: predicate
        )
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(
        notIn ids: [String]
    ) async throws -> [Object.PersistentObject.Object] {
        let predicate = NSPredicate(notIn: ids)
        return try await self.fetch(
            predicate: predicate
        )
    }

    // MARK: - Fetch All

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

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
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

@available(iOS 13.0.0, *)
public extension ObjectStore {

    // MARK: - Deletion by NSPredicate

    func delete(
        predicate: NSPredicate?
    ) throws {
        let request = self.newFetchRequest(predicate: predicate)
        for object in try self.context.fetch(request) {
            self.context.delete(object)
        }
        try self.saveChanges()
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func delete(
        predicate: NSPredicate?
    ) async throws {
        return try await self.context.perform {
            let request = self.newFetchRequest(predicate: predicate)
            for object in try context.fetch(request) {
                self.context.delete(object)
            }
            try self.saveChanges()
        }
    }

    // MARK: - Delete One

    func deleteOne(id: String) throws {
        let predicate = NSPredicate(id: id)
        try self.delete(predicate: predicate)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteOne(id: String) async throws {
        let predicate = NSPredicate(id: id)
        try await self.delete(predicate: predicate)
    }

    // MARK: - Delete Many

    func deleteMany(in ids: [String]) throws {
        let predicate = NSPredicate(ids: ids)
        try self.delete(predicate: predicate)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(in ids: [String]) async throws {
        let predicate = NSPredicate(ids: ids)
        try await self.delete(predicate: predicate)
    }

    func deleteMany(notIn ids: [String]) throws {
        let predicate = NSPredicate(notIn: ids)
        try self.delete(predicate: predicate)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(notIn ids: [String]) async throws {
        let predicate = NSPredicate(notIn: ids)
        try await self.delete(predicate: predicate)
    }

    // MARK: - Delete All

    func deleteAll() throws {
        try self.delete(predicate: nil)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteAll() async throws {
        try await self.delete(predicate: nil)
    }
}
