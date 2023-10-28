//
//  ObjectStoreError.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - ObjectStoreError

internal enum ObjectStoreError : Error {
    case unableToCreate(entityName: String)
}
