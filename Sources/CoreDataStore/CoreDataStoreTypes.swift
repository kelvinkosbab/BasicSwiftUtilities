//
//  CoreDataStoreTypes.swift
//
//  Created by Kelvin Kosbab on 10/14/21.
//

import Foundation
import CoreData

// MARK: - StructConvertable

public protocol StructConvertable : NSManagedObject, CoreDataIdentifiable & CoreDataObject {
    associatedtype StructType : CoreDataAssociated
    
    func toStruct() -> StructType?
}

public extension Array where Element : StructConvertable {
    
    var valueObjects: [Element.StructType] {
        return self.compactMap { $0.toStruct() }
    }
}

public extension Set where Element : StructConvertable {
    
    var valueObjects: Set<Element.StructType> {
        var set = Set<Element.StructType>()
        let array = self.compactMap { $0.toStruct() }
        for element in array {
            set.insert(element)
        }
        return set
    }
}

// MARK: - CoreDataAssociated

public protocol CoreDataAssociated : Hashable {
    associatedtype ManagedObject : StructConvertable
}
