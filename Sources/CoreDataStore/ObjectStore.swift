//
//  ObjectStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - ObjectStore

@available(iOS 13.0.0, *)
public protocol ObjectStore  {
    
    associatedtype ObjectType
    
    // MARK: - Create Or Update
    
    func createOrUpdate(_ object: ObjectType)
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func createOrUpdate(_ object: ObjectType) async
    
    // MARK: - Fetch
    
    func fetchOne(id: String) -> ObjectType?
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchOne(id: String) async -> ObjectType?
    
    func fetchMany(in ids: [String]) -> [ObjectType]
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(in ids: [String]) async -> [ObjectType]
    
    func fetchMany(notIn ids: [String]) -> [ObjectType]
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func fetchMany(notIn ids: [String]) async -> [ObjectType]
    
    // MARK: - Delete
    
    func delete(_ object: ObjectType)
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func delete(_ object: ObjectType) async
    
    func deleteOne(id: String)
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteOne(id: String) async
    
    func deleteMany(in ids: [String])
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(in ids: [String]) async
    
    func deleteMany(notIn ids: [String])
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteMany(notIn ids: [String]) async
    
    func deleteAll()
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func deleteAll() async
}
