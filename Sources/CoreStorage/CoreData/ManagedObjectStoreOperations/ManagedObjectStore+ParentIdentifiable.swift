//
//  ManagedObjectStore+ParentIdentifiable.swift.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - ManagedObjectStore ParentIdentifiable

@available(iOS 13.0.0, *)
extension ManagedObjectStore where ObjectType.ManagedObject : ManagedObjectParentIdentifiable {
    
    // MARK: - Fetching
    
    func fetchOne(
        id: String,
        parentId: String
    ) throws -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        return try ManagedObject.fetchOne(predicate: predicate, context: self.context)?.structValue
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchOne(
        id: String,
        parentId: String
    ) async throws -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        return try await ManagedObject.fetchOne(predicate: predicate, context: self.context)?.structValue
    }

    func fetchMany(
        in ids: [String],
        parentId: String
    ) throws -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        return try ManagedObject.fetch(predicate: predicate, context: self.context).structValues
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(
        in ids: [String],
        parentId: String
    ) async throws -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        return await ManagedObject.fetch(predicate: predicate, context: self.context).structValues
    }

    func fetchMany(
        notIn ids: [String],
        parentId: String
    ) throws -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        return try ManagedObject.fetch(predicate: predicate, context: self.context).structValues
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
        try ManagedObject.delete(predicate: predicate, context: self.context)
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
        for object in try ManagedObject.fetch(predicate: predicate, context: self.context) {
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
        for object in try ManagedObject.fetch(predicate: predicate, context: self.context) {
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
        for object in try ManagedObject.fetch(predicate: predicate, context: self.context) {
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
