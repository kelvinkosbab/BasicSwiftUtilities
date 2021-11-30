//
//  ObjectStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - ObjectStore

public protocol ObjectStore  {
    
    associatedtype ObjectType
    
    func createOrUpdate(_ object: ObjectType)
    func fetchOne(id: String) -> ObjectType?
    func fetchMany(in ids: [String]) -> [ObjectType]
    func fetchMany(notIn ids: [String]) -> [ObjectType]
    func delete(_ object: ObjectType)
    func deleteOne(id: String)
    func deleteMany(in ids: [String])
    func deleteMany(notIn ids: [String])
    func deleteAll()
}
