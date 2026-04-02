//
//  Retry.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Retry

/// Retries a synchronous throwing closure with the given retry strategy.
///
/// Returns a closure that, when called, executes `block` up to `max` times. If `block`
/// throws and the error passes `retryIf`, the operation is retried after a delay determined
/// by `strategy`.
///
/// ```swift
/// let operation = retry(maxAttempts: 3, strategy: .constant(base: 500, jitterRange: 0)) {
///     try riskyOperation()
/// }
/// let result = operation()
/// ```
///
/// - Parameter max: Maximum number of attempts.
/// - Parameter strategy: The ``RetryStrategy`` controlling delay between attempts.
/// - Parameter retryIf: A predicate that determines whether a given error is eligible for retry.
///   Defaults to retrying all errors.
/// - Parameter block: The throwing closure to retry.
/// - Returns: A ``RetryReturn`` closure that performs the retry logic when called.
public func retry(
    maxAttempts max: UInt,
    strategy: RetryStrategy,
    retryIf shouldRetry: @escaping @Sendable (Error) -> Bool = { _ in true },
    block: @escaping RetryBlock
) -> RetryReturn {

    let queue = DispatchQueue(label: "BasicSwiftUtilities.Core.retry")
    let group = DispatchGroup()

    return {
        var attempts: UInt = 0
        while true {
            var blockSuccess = false
            do {
                try block()
                blockSuccess = true
            } catch {
                if !shouldRetry(error) || attempts + 1 == max {
                    return .failure(error: error)
                }
            }

            if blockSuccess {
                return .success(attempts: attempts)
            }

            attempts += 1

            if attempts < max {
                let timer = DispatchWorkItem(block: group.leave)
                let delay = strategy.calculateDelay(attempts: attempts)
                group.enter()
                queue.asyncAfter(deadline: .now() + delay / MILLISECONDS_IN_SECOND, execute: timer)
                group.wait()
            }
        }
    }
}
