//
//  ManagedObjectTypes.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - ManagedObjectIdentifiable

/// Defines an object (recommended to be a `NSManagedObject` subclass) which has a unique `identifier` property.
public protocol ManagedObjectIdentifiable {
    
    /// Unique `identifier` of the object in the `CoreData` entity.
    var identifier: String? { get set }
}

// MARK: - ManagedObjectParentIdentifiable

/// Defines an `NSManagedObject` subclass which has a unique `parentIdentifier` property.
public protocol ManagedObjectParentIdentifiable {
    
    /// The unique `identifier` of the partent object of the object in the `CoreData` entity.
    var parentIdentifier: String? { get set }
}
