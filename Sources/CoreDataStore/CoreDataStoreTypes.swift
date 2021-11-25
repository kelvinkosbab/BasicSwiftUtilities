//
//  CoreDataStoreTypes.swift
//
//  Created by Kelvin Kosbab on 10/14/21.
//

import Foundation
import CoreData

// MARK: - CoreDataIdentifiable

public protocol CoreDataIdentifiable {
    var identifier: String? { get set }
}

public protocol ObjectIdentifiable {
    var identifier: String { get }
}

public protocol CoreDataParentIdentifiable {
    var parentIdentifier: String? { get set }
}

// MARK: - StructConvertable

public protocol StructConvertable : NSManagedObject, CoreDataIdentifiable {
    associatedtype StructType : CoreDataAssociated
    
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

// MARK: - CoreDataAssociated

public protocol CoreDataAssociated : Hashable, ObjectIdentifiable {
    associatedtype ManagedObject : StructConvertable
}
