//
//  DataStoreContainer.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - StoreContainer

/// Represents a local data store container.
public protocol StoreContainer {
    
    /// The name of the core data model store. Should match the name of the *.xcdatamodeld file.
    var storeName: String { get }
}
