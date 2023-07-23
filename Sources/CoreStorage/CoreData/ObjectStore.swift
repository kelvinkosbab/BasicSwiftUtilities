//
//  ObjectStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - ObjectStore

/// Defines operations for the `CoreData` object store including creating, updating, fetching, and deleting objects.
public protocol ObjectStore  {
    
    associatedtype ObjectType
    
    // MARK: - Create Or Update
    
    /// Creates or updates the given object by its ID.
    ///
    /// - Parameter object: Object to create or update.
    func createOrUpdate(_ object: ObjectType)
    
    /// Asyncronously creates or updates the given object by its ID.
    ///
    /// - Parameter object: Object to create or update.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func createOrUpdate(_ object: ObjectType) async
    
    // MARK: - Fetch
    
    /// Fetches an object with the given ID.
    ///
    /// - Returns: The value type of the object if it exists in the data store.
    func fetchOne(id: String) -> ObjectType?
    
    /// Asyncronously fetches an object with the given ID.
    ///
    /// - Returns: The value type of the object if it exists in the data store.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchOne(id: String) async -> ObjectType?
    
    /// Fetches objects with the given IDs.
    ///
    /// - Returns: The value types of the objects if they exist in the data store.
    func fetchMany(in ids: [String]) -> [ObjectType]
    
    /// Asyncronously fetches objects with the given IDs.
    ///
    /// - Returns: The value types of the objects if they exist in the data store.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(in ids: [String]) async -> [ObjectType]
    
    /// Fetches objects not with the given IDs.
    ///
    /// - Returns: The value types of the objects if they exist in the data store.
    func fetchMany(notIn ids: [String]) -> [ObjectType]
    
    /// Asyncronously fetches objects not with the given IDs.
    ///
    /// - Returns: The value types of the objects if they exist in the data store.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(notIn ids: [String]) async -> [ObjectType]
    
    // MARK: - Delete
    
    /// Deletes the object if it exists in the data store.
    ///
    /// - Parameter object: Object to delete.
    func delete(_ object: ObjectType)
    
    /// Asyncronously deletes the object if it exists in the data store.
    ///
    /// - Parameter object: Object to delete.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func delete(_ object: ObjectType) async
    
    /// Asyncronously deletes the object if it exists in the data store.
    ///
    /// - Parameter id: ID of the object to delete in the data store.
    func deleteOne(id: String)
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteOne(id: String) async
    
    /// Deletes all objects in the provided IDs in the data store.
    ///
    /// - Parameter ids: IDs of the objects to delete in the data store.
    func deleteMany(in ids: [String])
    
    /// Deletes all objects in the provided IDs in the data store.
    ///
    /// - Parameter ids: IDs of the objects to delete in the data store.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(in ids: [String]) async
    
    /// Asyncronously deletes all objects not in the provided IDs in the data store.
    ///
    /// - Parameter ids: IDs of the objects not to delete in the data store.
    func deleteMany(notIn ids: [String])
    
    /// Asyncronously deletes all objects not in the provided IDs in the data store.
    ///
    /// - Parameter ids: IDs of the objects not to delete in the data store.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(notIn ids: [String]) async
    
    /// Deletes all objects in the data store.
    func deleteAll()
    
    /// Asyncronously deletes all objects in the data store.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteAll() async
}
