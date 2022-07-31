//
//  ManagedObjectStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ManagedObjectStore

@available(iOS 13.0.0, *)
public protocol ManagedObjectStore : ObjectStore where ObjectType : ManagedObjectAssociated, ObjectType.ManagedObject.StructType == ObjectType {
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
    
    typealias ManagedObject = ObjectType.ManagedObject
    
    func saveChanges() throws {
        
        guard self.context.hasChanges else {
            return
        }
        
        try? self.context.save()
    }
    
    // MARK: - Create or Update
    
    func createOrUpdate(_ object: ObjectType) throws {
        var cdObject = ManagedObject.fetchOne(id: object.identifier, context: self.context) ?? ManagedObject.create(context: self.context)
        cdObject.structValue = object
        try self.saveChanges()
    }
    
    // MARK: - Fetching
    
    func fetchOne(id: String) -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return ManagedObject.fetchOne(predicate: predicate, context: self.context)?.structValue
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchOne(id: String) async -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return await ManagedObject.fetchOne(predicate: predicate, context: self.context)?.structValue
    }
    
    func fetchMany(in ids: [String]) -> [ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        let cdObjects = ManagedObject.fetch(predicate: predicate, context: self.context)
        return cdObjects.structValues
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(in ids: [String]) async -> [ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        let cdObjects = await ManagedObject.fetch(predicate: predicate, context: self.context)
        return cdObjects.structValues
    }
    
    func fetchMany(notIn ids: [String]) -> [ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        let cdObjects = ManagedObject.fetch(predicate: predicate, context: self.context)
        return cdObjects.structValues
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(notIn ids: [String]) async -> [ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        let cdObjects = await ManagedObject.fetch(predicate: predicate, context: self.context)
        return cdObjects.structValues
    }
    
    func fetchAll(sortDescriptors: [NSSortDescriptor]?) -> [ManagedObject.StructType] {
        let request = ManagedObject.newFetchRequest(sortDescriptors: sortDescriptors)
        request.returnsObjectsAsFaults = false
        return ManagedObject.fetch(predicate: nil, sortDescriptors: sortDescriptors, context: self.context).structValues
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchAll(sortDescriptors: [NSSortDescriptor]?) async -> [ManagedObject.StructType] {
        let request = ManagedObject.newFetchRequest(sortDescriptors: sortDescriptors)
        request.returnsObjectsAsFaults = false
        return await ManagedObject.fetch(predicate: nil, sortDescriptors: sortDescriptors, context: self.context).structValues
    }
    
    // MARK: - Delete
    
    func delete(_ object: ObjectType) throws {
        self.deleteOne(id: object.identifier)
        try self.saveChanges()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func delete(_ object: ObjectType) async throws {
        await self.deleteOne(id: object.identifier)
        try self.saveChanges()
    }
    
    func deleteOne(id: String) throws{
        let predicate = QueryPredicate.getPredicate(id: id)
        ManagedObject.delete(predicate: predicate, context: self.context)
        try self.saveChanges()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteOne(id: String) async throws{
        let predicate = QueryPredicate.getPredicate(id: id)
        await ManagedObject.delete(predicate: predicate, context: self.context)
        try self.saveChanges()
    }
    
    func deleteMany(in ids: [String]) throws {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        for object in ManagedObject.fetch(predicate: predicate, context: self.context) {
            object.delete(context: self.context)
        }
        try self.saveChanges()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(in ids: [String]) async throws {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        await ManagedObject.delete(predicate: predicate, context: context)
        try self.saveChanges()
    }
    
    func deleteMany(notIn ids: [String]) throws {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        for object in ManagedObject.fetch(predicate: predicate, context: self.context) {
            object.delete(context: self.context)
        }
        try self.saveChanges()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(notIn ids: [String]) async throws {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        await ManagedObject.delete(predicate: predicate, context: context)
        try self.saveChanges()
    }
    
    func deleteAll() throws {
        for object in ManagedObject.fetch(predicate: nil, sortDescriptors: nil, context: self.context) {
            object.delete(context: self.context)
        }
        try self.saveChanges()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteAll() async throws {
        await ManagedObject.delete(predicate: nil, context: self.context)
        try self.saveChanges()
    }
}

// MARK: - Parent and Child

@available(iOS 13.0.0, *)
extension ManagedObjectStore where ObjectType.ManagedObject : ManagedObjectParentIdentifiable {
    
    // MARK: - Fetching
    
    func fetchOne(
        id: String,
        parentId: String
    ) -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        return ManagedObject.fetchOne(predicate: predicate, context: self.context)?.structValue
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchOne(
        id: String,
        parentId: String
    ) async -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        return await ManagedObject.fetchOne(predicate: predicate, context: self.context)?.structValue
    }

    func fetchMany(
        in ids: [String],
        parentId: String
    ) -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        return ManagedObject.fetch(predicate: predicate, context: self.context).structValues
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(
        in ids: [String],
        parentId: String
    ) async -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        return await ManagedObject.fetch(predicate: predicate, context: self.context).structValues
    }

    func fetchMany(
        notIn ids: [String],
        parentId: String
    ) -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        return ManagedObject.fetch(predicate: predicate, context: self.context).structValues
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(
        notIn ids: [String],
        parentId: String
    ) async -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        return await ManagedObject.fetch(predicate: predicate, context: self.context).structValues
    }
    
    // MARK: - Delete
    
    func deleteOne(
        id: String,
        parentId: String
    ) throws {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        ManagedObject.delete(predicate: predicate, context: self.context)
        try self.saveChanges()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteOne(
        id: String,
        parentId: String
    ) async throws {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        await ManagedObject.delete(predicate: predicate, context: self.context)
        try self.saveChanges()
    }
    
    func deleteMany(
        in ids: [String],
        parentId: String
    ) throws {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        for object in ManagedObject.fetch(predicate: predicate, context: self.context) {
            object.delete(context: self.context)
        }
        try self.saveChanges()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(
        in ids: [String],
        parentId: String
    ) async throws {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        await ManagedObject.delete(predicate: predicate, context: self.context)
        try self.saveChanges()
    }
    
    func deleteMany(
        notIn ids: [String],
        parentId: String
    ) throws {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        for object in ManagedObject.fetch(predicate: predicate, context: self.context) {
            object.delete(context: self.context)
        }
        try self.saveChanges()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(
        notIn ids: [String],
        parentId: String
    ) async throws {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        await ManagedObject.delete(predicate: predicate, context: self.context)
        try self.saveChanges()
    }
    
    func deleteMany(parentId: String) throws {
        let predicate = QueryPredicate.getPredicate(parentId: parentId)
        for object in ManagedObject.fetch(predicate: predicate, context: self.context) {
            object.delete(context: self.context)
        }
        try self.saveChanges()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(parentId: String) async throws {
        let predicate = QueryPredicate.getPredicate(parentId: parentId)
        await ManagedObject.delete(predicate: predicate, context: self.context)
        try self.saveChanges()
    }
}
