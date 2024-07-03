//
//  QueryResult.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

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

#endif
