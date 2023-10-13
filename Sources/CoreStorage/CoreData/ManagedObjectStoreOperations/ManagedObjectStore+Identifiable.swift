//
//  ManagedObjectStore+Identifiable.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - ManagedObjectStore Identifiable

@available(iOS 13.0.0, *)
public extension ManagedObjectStore {
    
    // MARK: - Fetching
    
    func fetchOne(id: String) throws -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return try ManagedObject.fetchOne(
            predicate: predicate,
            context: self.context
        )?.structValue
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchOne(id: String) async throws -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return try await ManagedObject.fetchOne(
            predicate: predicate,
            context: self.context
        )?.structValue
    }
    
    func fetchMany(in ids: [String]) throws -> [ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        return try ManagedObject.fetch(
            predicate: predicate,
            context: self.context
        ).structValues
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(in ids: [String]) async -> [ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        return await ManagedObject.fetch(
            predicate: predicate,
            context: self.context
        ).structValues
    }
    
    func fetchMany(notIn ids: [String]) throws -> [ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        return try ManagedObject.fetch(
            predicate: predicate,
            context: self.context
        ).structValues
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(notIn ids: [String]) async -> [ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        return await ManagedObject.fetch(
            predicate: predicate,
            context: self.context
        ).structValues
    }
    
    func fetchAll(sortDescriptors: [NSSortDescriptor]?) throws -> [ManagedObject.StructType] {
        let request = ManagedObject.newFetchRequest(sortDescriptors: sortDescriptors)
        request.returnsObjectsAsFaults = false
        return try ManagedObject.fetch(
            predicate: nil,
            sortDescriptors: sortDescriptors,
            context: self.context
        ).structValues
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchAll(sortDescriptors: [NSSortDescriptor]?) async -> [ManagedObject.StructType] {
        let request = ManagedObject.newFetchRequest(sortDescriptors: sortDescriptors)
        request.returnsObjectsAsFaults = false
        return await ManagedObject.fetch(
            predicate: nil,
            sortDescriptors: sortDescriptors,
            context: self.context
        ).structValues
    }
    
    // MARK: - Delete
    
    func delete(_ object: ObjectType) throws {
        try self.deleteOne(id: object.identifier)
        try self.saveChanges()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func delete(_ object: ObjectType) async throws {
        try await self.deleteOne(id: object.identifier)
        try self.saveChanges()
    }
    
    func deleteOne(id: String) throws {
        let predicate = QueryPredicate.getPredicate(id: id)
        try ManagedObject.delete(predicate: predicate, context: self.context)
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
        for object in try ManagedObject.fetch(predicate: predicate, context: self.context) {
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
        for object in try ManagedObject.fetch(predicate: predicate, context: self.context) {
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
        for object in try ManagedObject.fetch(
            predicate: nil,
            sortDescriptors: nil,
            context: self.context
        ) {
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
