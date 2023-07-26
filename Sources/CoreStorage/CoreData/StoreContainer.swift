//
//  DataStoreContainer.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - StoreContainer

/// Represents a data store container.
public protocol StoreContainer {
    
    /// The name of the core data model store. Should match the name of the `<storeName>.xcdatamodeld` file.
    var storeName: String { get }
}
