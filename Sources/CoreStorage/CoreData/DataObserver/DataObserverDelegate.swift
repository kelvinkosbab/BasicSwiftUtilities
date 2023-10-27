//
//  DataObserverDelegate.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - DataObserverDelegate

/// Deflines the interface for objects to listen to underlyhing data store udpates for a given data type.
public protocol DataObserverDelegate : AnyObject where ObjectType == ObjectType.PersistentObject.Object {
    
    /// Object which is associated with a `CoreData` manged object.
    associatedtype ObjectType : AssociatedWithPersistentObject
    
    /// Called when an object is added to the data store.
    ///
    /// - Parameter object: Object which was added to the data store.
    func didAdd(object: ObjectType) -> Void
    
    /// Called when an object is updated in the data store.
    ///
    /// - Parameter object: Object which was updated in the data store.
    func didUpdate(object: ObjectType) -> Void
    
    /// Called when an object is removed from the data store.
    ///
    /// - Parameter object: Object which was removed from the data store.
    func didRemove(object: ObjectType) -> Void
}
