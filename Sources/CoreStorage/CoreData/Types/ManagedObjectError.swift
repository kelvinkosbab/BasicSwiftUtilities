//
//  ManagedObjectError.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - ManagedObjectError

public enum ManagedObjectError : Error, LocalizedError {
    case invalidEntity(String)
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
            case .invalidEntity(let message):
            return message
        }
    }
}
