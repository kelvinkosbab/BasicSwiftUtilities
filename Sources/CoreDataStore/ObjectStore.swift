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
    
    func createOrUpdate(_ object: ObjectType)
    func createOrUpdate(_ object: ObjectType) async
    func fetchOne(id: String) -> ObjectType?
    func fetchOne(id: String) async -> ObjectType?
    func fetchMany(in ids: [String]) -> [ObjectType]
    func fetchMany(in ids: [String]) async -> [ObjectType]
    func fetchMany(notIn ids: [String]) -> [ObjectType]
    func fetchMany(notIn ids: [String]) async -> [ObjectType]
    func delete(_ object: ObjectType)
    func delete(_ object: ObjectType) async
    func deleteOne(id: String)
    func deleteOne(id: String) async
    func deleteMany(in ids: [String])
    func deleteMany(in ids: [String]) async
    func deleteMany(notIn ids: [String])
    func deleteMany(notIn ids: [String]) async
    func deleteAll()
    func deleteAll() async
}
