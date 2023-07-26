//
//  Types.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - Managed Object Types

/// Defines an object (recommended to be a `NSManagedObject` subclass) which has a unique `identifier` property.
public protocol ManagedObjectIdentifiable {
    
    /// Unique `identifier` of the object in the `CoreData` entity.
    var identifier: String? { get set }
}

/// Defines an `NSManagedObject` subclass which has a unique `parentIdentifier` property.
public protocol ManagedObjectParentIdentifiable {
    
    /// The unique `identifier` of the partent object of the object in the `CoreData` entity.
    var parentIdentifier: String? { get set }
}

public protocol ManagedObjectAssociated : Hashable, ObjectIdentifiable {
    associatedtype ManagedObject : NSManagedObject, StructConvertable, ManagedObjectIdentifiable
}

// MARK: - Struct Types

/// Defines an object with a unique `identifier` property. It is recommended that this object is a `struct`.
public protocol ObjectIdentifiable {
    
    /// Unique `identifier` of the object.
    var identifier: String { get }
}

/// Defines an object with a unique `identifier` property. It is recommended that this object is a `struct`.
public protocol ObjectParentIdentifiable {
    
    /// Unique `parentIdentifier` of the object.
    var parentIdentifier: String { get }
}

// MARK: - StructConvertable

/// Defines an object (recommended to be a `NSManagedObject` subclass) which can be converted to a `struct`.
public protocol StructConvertable {
    
    associatedtype StructType : Hashable
    
    /// Returns the `struct` value type of the object
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

/// A simple success vs failure result for a storage operation.
public enum Result {
    
    /// The operation succeeded.
    case success
    
    /// The operation failed:
    ///
    /// - Parameter error: The error that was thrown during the operation.
    case failure(Error)
}
