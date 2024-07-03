//
//  AsyncRetry.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - AsyncRetry

public func asyncRetry<T>(
    max: UInt,
    strategy: RetryStrategy,
    retryIf shouldRetry: @escaping (Error) -> Bool = { _ in true },
    block: @escaping AsyncRetryBlock<T>
) -> AsyncRetryReturn<T> {

    let queue = DispatchQueue(label: "BasicSwiftUtilities.Core.retry")
    let group = DispatchGroup()

    var attempts: UInt = 0

    return {
        while true {

            // Try to run the async block.
            do {
                let result = try await block()
                return .success(attempts: attempts, value: result)
            } catch {
                if !shouldRetry(error) || attempts + 1 == max {
                    return .failure(error: error)
                }
            }

            // If failure, increment the retry attempts counter.
            attempts += 1

            // Delay using the provided strategy (do not delay on the last failure).
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
