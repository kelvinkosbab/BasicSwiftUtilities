//
//  QueryResult.swift
//
//  Created by Kelvin Kosbab on 10/2/22.
//

import Foundation

// MARK: - QueryResult

/// Defines an object that a query returns after executing.
public enum QueryResult {
    
    /// An error was thrown during the query.
    ///
    /// - Parameter error: Error encountered during query.
    case error(_ error: Error)
    
    /// The query completed successfully.
    ///
    /// - Parameter samples: The samples returned from the query.
    case success(samples: [Sample])
}
