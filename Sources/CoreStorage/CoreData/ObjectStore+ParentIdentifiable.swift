//
//  ObjectStore+ParentIdentifiable.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ObjectStore & ParentIdentifiable

public extension ObjectStore where Object : ObjectParentIdentifiable, PersistedObject : PersistedObjectParentIdentifiable {
    
    // MARK: - Fetching
    
    func fetchOne(
        id: String,
        parentId: String
    ) throws -> Object.PersistentObject.Object? {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        return try self.fetchOne(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchOne(
        id: String,
        parentId: String
    ) async throws -> Object.PersistentObject.Object? {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        return try await self.fetchOne(predicate: predicate)
    }

    func fetchMany(
        in ids: [String],
        parentId: String
    ) throws -> [Object.PersistentObject.Object] {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        return try self.fetch(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(
        in ids: [String],
        parentId: String
    ) async throws -> [Object.PersistentObject.Object] {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        return try await self.fetch(predicate: predicate)
    }

    func fetchMany(
        notIn ids: [String],
        parentId: String
    ) throws -> [Object.PersistentObject.Object] {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        return try self.fetch(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(
        notIn ids: [String],
        parentId: String
    ) async throws -> [Object.PersistentObject.Object] {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        return try await self.fetch(predicate: predicate)
    }
    
    // MARK: - Delete
    
    func deleteOne(
        id: String,
        parentId: String
    ) throws {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        try self.delete(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteOne(
        id: String,
        parentId: String
    ) async throws {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        try await self.delete(predicate: predicate)
    }
    
    func deleteMany(
        in ids: [String],
        parentId: String
    ) throws {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        try self.delete(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(
        in ids: [String],
        parentId: String
    ) async throws {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        try await self.delete(predicate: predicate)
    }
    
    func deleteMany(
        notIn ids: [String],
        parentId: String
    ) throws {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        try self.delete(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(
        notIn ids: [String],
        parentId: String
    ) async throws {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        try await self.delete(predicate: predicate)
    }
    
    func deleteMany(parentId: String) throws {
        let predicate = QueryPredicate.getPredicate(parentId: parentId)
        try self.delete(predicate: predicate)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(parentId: String) async throws {
        let predicate = QueryPredicate.getPredicate(parentId: parentId)
        try await self.delete(predicate: predicate)
    }
}
