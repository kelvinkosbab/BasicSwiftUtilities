//
//  ObjectStoreError.swift
//
//  Copyright © Kozinga. All rights reserved.
//

public import Foundation

// MARK: - ObjectStoreError

/// Errors thrown by ``ObjectStore`` when CoreData operations fail.
public enum ObjectStoreError: LocalizedError, Sendable {

    /// Failed to create a new managed object instance for the named entity.
    ///
    /// This typically indicates a mismatch between the registered entity and the
    /// expected `NSManagedObject` subclass type.
    case unableToCreate(entityName: String)

    public var errorDescription: String? {
        switch self {
        case .unableToCreate(let entityName):
            "Failed to create a new managed object for entity \"\(entityName)\"."
        }
    }
}
