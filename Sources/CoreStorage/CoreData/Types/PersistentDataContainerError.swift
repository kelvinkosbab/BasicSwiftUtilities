//
//  PersistentDataContainerError.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - PersistentDataContainerError

/// Defines errors for creating a managed object container.
public enum PersistentDataContainerError : Swift.Error, LocalizedError {
    
    /// Defines an error where the managed object store could not be located with the given store name in the given bundle..
    case failedToLocateModel(name: String, bundle: Bundle)
    
    /// Defines an error where the `NSManagedObjectModel` failed to be loaded at the given URL.
    case failedToLoadModel(url: URL)
    
    public var errorDescription: String? {
        switch self {
        case .failedToLocateModel(name: let name, bundle: let bundle):
            return "Failed to load managed object model \(name).momd from bundle \(bundle)"
        case .failedToLoadModel(url: let url):
            return "Failed to load NSManagedObjectModel from url: \(url)"
        }
    }
}
