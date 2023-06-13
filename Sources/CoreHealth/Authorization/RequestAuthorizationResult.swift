//
//  RequestAuthorizationResult.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - RequestAuthorizationResult

public enum RequestAuthorizationResult {
    
    /// An error was thrown during the query.
    ///
    /// - Parameter error: Error encountered during query.
    case error(_ error: Error)
    
    /// The request succeeded.
    ///
    /// - Note: This does not indicate whether the user actually granted permission.
    case success
}
