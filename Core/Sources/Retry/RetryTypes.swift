//
//  RetryTypes.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Constants

internal let MILLISECONDS_IN_SECOND: Double = 1_000

// MARK: - Retry Types

/// The outcome of a ``retry(maxAttempts:strategy:retryIf:block:)`` operation.
public enum RetryResult: Sendable {

    /// The retry succeeded.
    ///
    /// - Parameter attempts: The number of retry attempts before success (0 means first try).
    case success(attempts: UInt)

    /// The retry failed after exhausting all attempts.
    ///
    /// - Parameter error: The error from the final attempt.
    case failure(error: Error)
}

/// A throwing closure to retry.
public typealias RetryBlock = @Sendable () throws -> Void

/// A closure that executes the retry logic and returns a ``RetryResult``.
public typealias RetryReturn = @Sendable () -> RetryResult

// MARK: - AsyncRetry Types

/// The outcome of an ``asyncRetry(max:strategy:retryIf:block:)`` operation.
public enum AsyncRetryResult<T: Sendable>: Sendable {

    /// The retry succeeded.
    ///
    /// - Parameter attempts: The number of retry attempts before success (0 means first try).
    /// - Parameter value: The value produced by the successful operation.
    case success(attempts: UInt, value: T)

    /// The retry failed after exhausting all attempts.
    ///
    /// - Parameter error: The error from the final attempt.
    case failure(error: Error)
}

/// An async throwing closure to retry.
public typealias AsyncRetryBlock<T: Sendable> = @Sendable () async throws -> T

/// A closure that executes the async retry logic and returns an ``AsyncRetryResult``.
public typealias AsyncRetryReturn<T: Sendable> = @Sendable () async -> AsyncRetryResult<T>
