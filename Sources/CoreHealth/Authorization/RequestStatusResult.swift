//
//  RequestStatusResult.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import HealthKit

// MARK: - RequestStatusResult

/// Defines an object that an authorization check returns after executing.
@available(macOS 13.0, watchOS 5.0, *)
public enum RequestStatusResult {
    
    /// An error was thrown during the query.
    ///
    /// - Parameter error: Error encountered during query.
    case error(_ error: Error)
    
    /// The query completed successfully.
    ///
    /// - Parameter status: The status returned by the request..
    case success(status: HKAuthorizationRequestStatus)
}

#endif
