//
//  StructConvertable.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - StructConvertable

/// Defines an object (recommended to be a `NSManagedObject` subclass) which can be converted to its
/// associated `struct` object.
public protocol StructConvertable {
    
    /// Defines the type of the associated object
    associatedtype Object : Hashable
    
    /// The getter returns the `struct` value type of the object. The setter updates this object with the value of the
    /// passed associated object.
    var structValue: Object? { get set }
}

public extension Array where Element : StructConvertable {
    
    /// Maps an array of `StructConvertable` objects to an array of their corresponding `StructType` types.
    var structValues: [Element.Object] {
        return self.compactMap { $0.structValue }
    }
}

public extension Set where Element : StructConvertable {
    
    /// Maps a set of `StructConvertable` to a set of their corresponding `StructType` types.
    var structValues: Set<Element.Object> {
        var set = Set<Element.Object>()
        let array = self.compactMap { $0.structValue }
        for element in array {
            set.insert(element)
        }
        return set
    }
}
