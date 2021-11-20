//
//  CoreDataError.swift
//  
//  Created by Kelvin Kosbab on 11/19/21.
//

import Foundation

// MARK: - CoreDataError

public enum CoreDataError : Error {
    case invalidEntity(String)
}

extension CoreDataError : LocalizedError {
    
    /// A localized message describing what error occurred.
     public var errorDescription: String? {
        switch self {
        case .invalidEntity(let message): return message
        }
    }
}
