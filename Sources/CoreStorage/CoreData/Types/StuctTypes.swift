//
//  StructTypes.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ObjectIdentifiable

/// Defines an object with a unique `identifier` property. It is recommended that this object is a `struct`.
public protocol ObjectIdentifiable {

    /// Unique `identifier` of the object.
    var identifier: String { get }
}

// MARK: - ObjectParentIdentifiable

/// Defines an object with a unique `identifier` property. It is recommended that this object is a `struct`.
public protocol ObjectParentIdentifiable {

    /// Unique `parentIdentifier` of the object.
    var parentIdentifier: String { get }
}

// MARK: - AssociatedWithPersistentObject

/// Defines an object that is associated with a `NSManagedObjectType`.
public protocol AssociatedWithPersistentObject: Hashable, ObjectIdentifiable {
    associatedtype PersistentObject: NSManagedObject, StructConvertable, PersistentObjectIdentifiable
}
