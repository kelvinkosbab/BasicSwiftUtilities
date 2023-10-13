//
//  StructConvertable.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - StructConvertable

/// Defines an object (recommended to be a `NSManagedObject` subclass) which can be converted to a `struct`.
public protocol StructConvertable {
    
    associatedtype StructType : Hashable
    
    /// Returns the `struct` value type of the object
    var structValue: StructType? { get set }
}

public extension Array where Element : StructConvertable {
    
    /// Maps an array of `StructConvertable` objects to an array of their corresponding `StructType` types.
    var structValues: [Element.StructType] {
        return self.compactMap { $0.structValue }
    }
}

public extension Set where Element : StructConvertable {
    
    /// Maps a set of `StructConvertable` to a set of their corresponding `StructType` types.
    var structValues: Set<Element.StructType> {
        var set = Set<Element.StructType>()
        let array = self.compactMap { $0.structValue }
        for element in array {
            set.insert(element)
        }
        return set
    }
}
