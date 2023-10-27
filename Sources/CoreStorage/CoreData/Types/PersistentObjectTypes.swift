//
//  PersistentObjectTypes.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - PersistentObjectIdentifiable

/// Defines an object (recommended to be a `NSManagedObject` subclass) which has a unique `identifier` property.
public protocol PersistentObjectIdentifiable {
    
    /// Unique `identifier` of the object in the `CoreData` entity.
    var identifier: String? { get set }
}

// MARK: - PersistedObjectParentIdentifiable

/// Defines an `NSManagedObject` subclass which has a unique `parentIdentifier` property.
public protocol PersistedObjectParentIdentifiable {
    
    /// The unique `identifier` of the partent object of the object in the `CoreData` entity.
    var parentIdentifier: String? { get set }
}
