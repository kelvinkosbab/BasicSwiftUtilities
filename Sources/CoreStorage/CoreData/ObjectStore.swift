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
    
    var context: NSManagedObjectContext { get }
}

@available(iOS 13.0.0, *)
internal extension ObjectStore {
    
    // MARK: - Save
    
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
    
    func create() -> Object.PersistentObject {
        let object = NSEntityDescription.insertNewObject(
            forEntityName: self.entityName,
            into: self.context
        ) as! Object.PersistentObject
        return object
    }
}

// MARK: - Create or Update

@available(iOS 13.0.0, *)
public extension ObjectStore {
    
    func createOrUpdate(_ object: Object) throws {
        let predicate = QueryPredicate.getPredicate(id: object.identifier)
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
    
    // MARK: - Fetch by Predicate
    
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
    
    func fetchOne(
        predicate: NSPredicate
    ) throws -> Object.PersistentObject.Object? {
        return try self.fetch(
            predicate: predicate,
            sortDescriptors: nil
        ).first
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchOne(
        predicate: NSPredicate
    ) async throws -> Object.PersistentObject.Object? {
        return try await self.context.perform {
            let request = self.newFetchRequest(predicate: predicate)
            return try self.context.fetch(request).first?.structValue
        }
    }
    
    // MARK: - Fetch One
    
    func fetchOne(
        id: String
    ) throws -> Object.PersistentObject.Object? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return try self.fetchOne(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchOne(
        id: String
    ) async throws -> Object.PersistentObject.Object? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return try await self.fetchOne(
            predicate: predicate
        )
    }
    
    // MARK: - Fetch Many
    
    func fetchMany(
        in ids: [String]
    ) throws -> [Object.PersistentObject.Object] {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        return try self.fetch(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(
        in ids: [String]
    ) async throws -> [Object.PersistentObject.Object] {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        return try await self.fetch(
            predicate: predicate
        )
    }
    
    func fetchMany(
        notIn ids: [String]
    ) throws -> [Object.PersistentObject.Object] {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        return try self.fetch(
            predicate: predicate
        )
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(
        notIn ids: [String]
    ) async throws -> [Object.PersistentObject.Object] {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        return try await self.fetch(
            predicate: predicate
        )
    }
    
    // MARK: - Fetch All
    
    func fetchAll(
        sortDescriptors: [NSSortDescriptor]?
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
        sortDescriptors: [NSSortDescriptor]?
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
    
    // MARK: - Deletion by Predicate
    
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
    
    func delete(_ object: Object) throws {
        let predicate = QueryPredicate.getPredicate(id: object.identifier)
        try self.delete(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func delete(_ object: Object) async throws {
        let predicate = QueryPredicate.getPredicate(id: object.identifier)
        try await self.delete(predicate: predicate)
    }
    
    func deleteOne(id: String) throws {
        let predicate = QueryPredicate.getPredicate(id: id)
        try self.delete(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteOne(id: String) async throws{
        let predicate = QueryPredicate.getPredicate(id: id)
        try await self.delete(predicate: predicate)
    }
    
    // MARK: - Delete Many
    
    func deleteMany(in ids: [String]) throws {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        try self.delete(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(in ids: [String]) async throws {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        try await self.delete(predicate: predicate)
    }
    
    func deleteMany(notIn ids: [String]) throws {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        try self.delete(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(notIn ids: [String]) async throws {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
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
