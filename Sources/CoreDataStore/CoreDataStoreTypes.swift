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

public protocol CoreDataAssociated : Hashable, Codable {
    associatedtype ManagedObject : StructConvertable
}

// MARK: - IdentifiableObject

/// Use the Identifiable protocol to provide a stable notion of identity to a class or value type. For example, you could define a User type
/// with an id property that is stable across your app and your app’s database storage. You could use the id property to identify a
/// particular user even if other data fields change, such as the user’s name.
///
/// Identifiable leaves the duration and scope of the identity unspecified. Identities could be any of the following:
/// * Guaranteed always unique (e.g. UUIDs).
/// * Unique for the lifetime of an object (e.g. object identifiers).
///
/// It is up to both the conformer and the receiver of the protocol to document the nature of the identity.
public protocol IdentifiableObject {
    var identifier: String { get }
}

// MARK: - IdentifiableParent

/// Use the Identifiable protocol to provide a stable notion of identity to a class or value type's parent object.
///
/// Identifiable leaves the duration and scope of the identity unspecified. Identities could be any of the following:
/// * Guaranteed always unique (e.g. UUIDs).
/// * Unique for the lifetime of an object (e.g. object identifiers).
///
/// It is up to both the conformer and the receiver of the protocol to document the nature of the identity.
public protocol IdentifiableParent {
    var parentIdentifier: String { get }
}
