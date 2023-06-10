//
//  RequestStatusResult.swift
//
//  Created by Kelvin Kosbab on 10/6/22.
//

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
