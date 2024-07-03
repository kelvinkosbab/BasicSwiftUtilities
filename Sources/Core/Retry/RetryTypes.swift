//
//  RetryTypes.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Types

internal let MILLISECONDS_IN_SECOND: Double = 1_000
internal let NANOSECONDS_IN_SECOND: Double = 1_000_000_000

// MARK: - Retry Types

/// Outcome of `retry`. It either succeeds or fails.
public enum RetryResult {

    /// The retry succeeded.
    ///
    /// - Parameter attempts: The number of attempts it took to succeed.
    case success(attempts: UInt)

    /// The retry failed.
    ///
    /// - Parameter error: The error thrown by the retry attempt.
    case failure(error: Error)
}

public typealias RetryBlock = () throws -> Void
public typealias RetryReturn = () -> RetryResult

// MARK: - AsyncRetry Types

/// Outcome of `asyncRetry`. It either succeeds or fails.
public enum AsyncRetryResult<T> {

    /// The retry succeeded.
    ///
    /// - Parameter attempts: The number of attempts it took to succeed.
    /// - Parameter value: The value of the successful operation.
    case success(attempts: UInt, value: T)

    /// The retry failed.
    ///
    /// - Parameter error: The error thrown by the retry attempt.
    case failure(error: Error)
}

public typealias AsyncRetryBlock<T> = () async throws -> T
public typealias AsyncRetryReturn<T> = () async -> AsyncRetryResult<T>
