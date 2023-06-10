//
//  Types.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - Managed Object Types

public protocol ManagedObjectIdentifiable {
    var identifier: String? { get set }
}

public protocol ManagedObjectParentIdentifiable {
    var parentIdentifier: String? { get set }
}

public protocol ManagedObjectAssociated : Hashable, ObjectIdentifiable {
    associatedtype ManagedObject : NSManagedObject, StructConvertable, ManagedObjectIdentifiable
}

// MARK: - Struct Types

public protocol ObjectIdentifiable {
    var identifier: String { get }
}

public protocol ObjectParentIdentifiable {
    var parentIdentifier: String { get }
}

// MARK: - StructConvertable

public protocol StructConvertable {
    associatedtype StructType : Hashable
    
    var structValue: StructType? { get set }
}

public extension Array where Element : StructConvertable {
    
    var structValues: [Element.StructType] {
        return self.compactMap { $0.structValue }
    }
}

public extension Set where Element : StructConvertable {
    
    var structValues: Set<Element.StructType> {
        var set = Set<Element.StructType>()
        let array = self.compactMap { $0.structValue }
        for element in array {
            set.insert(element)
        }
        return set
    }
}

// MARK: - Result

/// A simple success vs failure result. The failure result passes an `error: Error` parameter
/// of the error that was thrown.
public enum Result {
    case success
    case failure(Error)
}
