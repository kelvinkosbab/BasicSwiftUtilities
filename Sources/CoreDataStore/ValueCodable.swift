//
//  ValueCodable.swift
//
//  Created by Kelvin Kosbab on 10/14/21.
//

import Foundation

// MARK: - ValueCodable

public protocol ValueCodable {
    associatedtype ValueType : Hashable, Codable
    
    var valueObject: ValueType? { get set }
}

// MARK: - Array

public extension Array where Element : ValueCodable {
    
    var valueObjects: [Element.ValueType] {
        return self.compactMap { $0.valueObject }
    }
}

// MARK: - Set

public extension Set where Element : ValueCodable {
    
    var valueObjects: Set<Element.ValueType> {
        var set = Set<Element.ValueType>()
        let array = self.compactMap { $0.valueObject }
        for element in array {
            set.insert(element)
        }
        return set
    }
}
