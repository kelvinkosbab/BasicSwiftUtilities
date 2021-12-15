//
//  Types.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
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

extension StructConvertable where Self : NSManagedObject {
    
    static var entityName: String {
        return String(describing: Self.self)
    }
    
    static func create(context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: context) as! Self
    }
}
