//
//  AsyncRetry.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - AsyncRetry

/// Retries an async throwing closure with the given retry strategy.
///
/// Returns a closure that, when awaited, executes `block` up to `max` times. If `block`
/// throws and the error passes `retryIf`, the operation is retried after a delay determined
/// by `strategy`.
///
/// ```swift
/// let operation = asyncRetry(max: 3, strategy: .constant(base: 500, jitterRange: 0)) {
///     try await fetchData()
/// }
/// let result = await operation()
/// ```
///
/// - Parameter max: Maximum number of attempts. Values below 1 are treated as 1, so
///   `block` always runs at least once.
/// - Parameter strategy: The ``RetryStrategy`` controlling delay between attempts.
/// - Parameter retryIf: A predicate that determines whether a given error is eligible for retry.
///   Defaults to retrying all errors.
/// - Parameter block: The async throwing closure to retry.
/// - Returns: An ``AsyncRetryReturn`` closure that performs the retry logic when awaited.
public func asyncRetry<T: Sendable>(
    max: UInt,
    strategy: RetryStrategy,
    retryIf shouldRetry: @escaping @Sendable (Error) -> Bool = { _ in true },
    block: @escaping AsyncRetryBlock<T>
) -> AsyncRetryReturn<T> {

    // `max: 0` would otherwise never satisfy the exhaustion check and loop forever.
    let maxAttempts = Swift.max(max, 1)

    return {
        var attempts: UInt = 0
        while true {
            do {
                let result = try await block()
                return .success(attempts: attempts, value: result)
            } catch {
                if !shouldRetry(error) || attempts + 1 >= maxAttempts {
                    return .failure(error: error)
                }
            }

            attempts += 1

            if attempts < maxAttempts {
                let delay = strategy.calculateDelay(attempts: attempts)
                let seconds = delay / millisecondsInSecond
                do {
                    try await Task.sleep(for: .seconds(seconds))
                } catch {
                    // Cancellation surfaces as the error from the last attempt.
                    return .failure(error: error)
                }
            }
        }
    }
}
