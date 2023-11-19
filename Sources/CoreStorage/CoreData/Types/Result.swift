//
//  Result.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Result

/// A simple success vs failure result for a storage operation.
public enum Result {

    /// The operation succeeded.
    case success

    /// The operation failed:
    ///
    /// - Parameter error: The error that was thrown during the operation.
    case failure(Error)
}
