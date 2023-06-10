//
//  Retry.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Retry

/// Retries an asyncronous function in a blocking manner with the given retry strategy.
/// This function will wrap a closure that it receives as an agument.
/// It will retry the closure as many as `max` times if it fails.
///
/// - Parameter `max`: Number of retries.
/// - Parameter strategy: Strategy to be used for determining delay in between retries.
/// - Parameter retryIf: Indicates whether the passed-in error is eligible for retries. If it is not, it will short circuit all
/// retry logic and immediately return with `AsyncRetryResult<T>.failure`.
/// - Parameter block: An asynchronous closure that retry will wrap around and rety an case of a
/// failure. **MUST throw an error in case of failure**
///
/// - Returns: `AsyncRetryReturn<T>`, which is a closure that returns either `AsyncRetryResult<T>.success>` or
/// `AsyncRetryResult<T>.failure`.
public func retry(
    maxAttempts max: UInt,
    strategy: RetryStrategy,
    retryIf shouldRetry: @escaping (Error) -> Bool = { _ in true },
    block: @escaping RetryBlock
) -> RetryReturn {
    
    let queue = DispatchQueue(label: "BasicSwiftUtilities.Core.retry")
    let group = DispatchGroup()
    
    var attempts: UInt = 0
    
    return {
        while true {
            var blockSuccess = false
            // Try to run the block, and set the flag to true if it succeeds.
            do {
                try block()
                blockSuccess = true
            } catch {
                if !shouldRetry(error) || attempts + 1 == max {
                    return .failure(error: error)
                }
            }
            
            // Exit with success if block finished successfully.
            if blockSuccess {
                return .success(attempts: attempts)
            }
            
            // If failure, increment the retries attempts counter.
            attempts += 1
            
            // Delay using the provided strategy (do not display on the last failure)
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

/// Retries an asyncronous function in a blocking manner with the given retry strategy.
/// This function will wrap a closure that it receives as an agument.
/// It will retry the closure as many as `max` times if it fails.
///
/// - Parameter `max`: Number of retries.
/// - Parameter strategy: Strategy to be used for determining delay in between retries.
/// - Parameter block: @escaping RetryBlock
public func retry(
    maxAttempts max: UInt,
    strategy: RetryStrategy,
    block: @escaping RetryBlock
) -> RetryReturn {
    retry(maxAttempts: max, strategy: strategy, retryIf: { _ in true }, block: block)
}
