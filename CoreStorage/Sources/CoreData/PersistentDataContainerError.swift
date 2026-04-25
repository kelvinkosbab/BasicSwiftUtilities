//
//  PersistentDataContainerError.swift
//
//  Copyright © Kozinga. All rights reserved.
//

public import Foundation

// MARK: - PersistentDataContainerError

/// Defines errors for creating a managed object container.
public enum PersistentDataContainerError: Swift.Error, LocalizedError, Sendable {

    /// The managed object store could not be located with the given store name in the
    /// given bundle.
    case failedToLocateModel(name: String, bundleIdentifier: String?)

    /// The `NSManagedObjectModel` failed to be loaded at the given URL.
    case failedToLoadModel(url: URL)

    public var errorDescription: String? {
        switch self {
        case .failedToLocateModel(name: let name, bundleIdentifier: let bundleIdentifier):
            return "Failed to load managed object model \(name).momd from bundle \(bundleIdentifier ?? "<unknown>")"
        case .failedToLoadModel(url: let url):
            return "Failed to load NSManagedObjectModel from url: \(url)"
        }
    }
}
