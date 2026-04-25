//
//  RetryTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import Foundation
@testable import Core

// MARK: - RetryTests

@Suite("Retry")
struct RetryTests {

    // MARK: - Synchronous Retry

    @Test("Succeeds on first attempt and reports zero retry attempts")
    func succeedsOnFirstAttempt() throws {
        let operation = retry(maxAttempts: 3, strategy: .constant(base: 0, jitterRange: 0)) {
            // succeeds immediately
        }
        let result = operation()
        let attempts = try #require(result.successAttempts)
        #expect(attempts == 0)
    }

    @Test("Retries transient failures and succeeds on the third attempt")
    func retriesAndSucceeds() throws {
        let counter = LockedCounter()
        let operation = retry(maxAttempts: 3, strategy: .constant(base: 0, jitterRange: 0)) {
            let count = counter.increment()
            if count < 3 {
                throw TestError.transient
            }
        }
        let result = operation()
        let attempts = try #require(result.successAttempts)
        #expect(attempts == 2)
    }

    @Test("Returns failure after exhausting all attempts on permanent error")
    func failsAfterMaxAttempts() {
        let operation = retry(maxAttempts: 3, strategy: .constant(base: 0, jitterRange: 0)) {
            throw TestError.permanent
        }
        let result = operation()
        #expect(result.isFailure)
    }

    @Test("Short-circuits without further retries when retryIf returns false")
    func retryIfShortCircuits() {
        let counter = LockedCounter()
        let operation = retry(
            maxAttempts: 5,
            strategy: .constant(base: 0, jitterRange: 0),
            retryIf: { error in
                if let testError = error as? TestError {
                    return testError == .transient
                }
                return false
            }
        ) {
            counter.increment()
            throw TestError.permanent
        }
        let result = operation()
        #expect(counter.value == 1)
        #expect(result.isFailure)
    }

    // MARK: - Async Retry

    @Test("Async retry succeeds on first attempt and returns the value")
    func asyncSucceedsOnFirstAttempt() async throws {
        let operation = asyncRetry(max: 3, strategy: .constant(base: 0, jitterRange: 0)) {
            return 42
        }
        let result = await operation()
        let success = try #require(result.success)
        #expect(success.attempts == 0)
        #expect(success.value == 42)
    }

    @Test("Async retry retries transient failures and succeeds on the third attempt")
    func asyncRetriesAndSucceeds() async throws {
        let counter = Counter()
        let operation = asyncRetry(max: 3, strategy: .constant(base: 0, jitterRange: 0)) {
            let count = await counter.increment()
            if count < 3 {
                throw TestError.transient
            }
            return "done"
        }
        let result = await operation()
        let success = try #require(result.success)
        #expect(success.attempts == 2)
        #expect(success.value == "done")
    }

    @Test("Async retry returns failure after exhausting all attempts")
    func asyncFailsAfterMaxAttempts() async {
        let operation = asyncRetry(max: 2, strategy: .constant(base: 0, jitterRange: 0)) { () async throws -> Int in
            throw TestError.permanent
        }
        let result = await operation()
        #expect(result.isFailure)
    }

    // MARK: - RetryStrategy

    @Test("Exponential strategy doubles the delay each attempt up to the limit")
    func exponentialStrategy() {
        let strategy = RetryStrategy.exponential(base: 100, exponent: 2, limit: 1000, jitterRange: 0)
        let delay1 = strategy.calculateDelay(attempts: 1)
        let delay2 = strategy.calculateDelay(attempts: 2)
        let delay3 = strategy.calculateDelay(attempts: 3)
        let delay4 = strategy.calculateDelay(attempts: 4)
        #expect(delay1 == 100) // 100 * 2^0
        #expect(delay2 == 200) // 100 * 2^1
        #expect(delay3 == 400) // 100 * 2^2
        #expect(delay4 == 800) // 100 * 2^3
    }

    @Test("Exponential strategy caps the delay at the configured limit")
    func exponentialStrategyLimit() {
        let strategy = RetryStrategy.exponential(base: 100, exponent: 2, limit: 500, jitterRange: 0)
        let delay = strategy.calculateDelay(attempts: 4)
        #expect(delay == 500) // min(500, 800) = 500
    }

    @Test("Linear strategy adds the increment for each subsequent attempt")
    func linearStrategy() {
        let strategy = RetryStrategy.linear(base: 100, increment: 50, limit: 1000, jitterRange: 0)
        let delay1 = strategy.calculateDelay(attempts: 1)
        let delay2 = strategy.calculateDelay(attempts: 2)
        let delay3 = strategy.calculateDelay(attempts: 3)
        #expect(delay1 == 100) // 100 + 50*0
        #expect(delay2 == 150) // 100 + 50*1
        #expect(delay3 == 200) // 100 + 50*2
    }

    @Test("Constant strategy returns the same delay for every attempt")
    func constantStrategy() {
        let strategy = RetryStrategy.constant(base: 200, jitterRange: 0)
        let delay1 = strategy.calculateDelay(attempts: 1)
        let delay2 = strategy.calculateDelay(attempts: 5)
        #expect(delay1 == 200)
        #expect(delay2 == 200)
    }

    @Test("Custom strategy delegates delay calculation to the provided closure")
    func customStrategy() {
        let strategy = RetryStrategy.custom { attempts in
            return Double(attempts * 100)
        }
        let delay1 = strategy.calculateDelay(attempts: 1)
        let delay3 = strategy.calculateDelay(attempts: 3)
        #expect(delay1 == 100)
        #expect(delay3 == 300)
    }
}

// MARK: - Result Helpers

extension RetryResult {
    /// Returns `true` if the result is a `.failure` case.
    fileprivate var isFailure: Bool {
        if case .failure = self { true } else { false }
    }

    /// Returns the number of retry attempts when the result is `.success`, otherwise `nil`.
    fileprivate var successAttempts: UInt? {
        if case .success(let attempts) = self { attempts } else { nil }
    }
}

extension AsyncRetryResult {
    /// Returns `true` if the result is a `.failure` case.
    fileprivate var isFailure: Bool {
        if case .failure = self { true } else { false }
    }

    /// Returns the success payload (attempts + value) when the result is `.success`, otherwise `nil`.
    fileprivate var success: (attempts: UInt, value: T)? {
        if case .success(let attempts, let value) = self {
            (attempts: attempts, value: value)
        } else {
            nil
        }
    }
}

// MARK: - Helpers

private enum TestError: Error, Equatable {
    case transient
    case permanent
}

/// Thread-safe counter for synchronous retry tests.
///
/// `Mutex` would be the modern Swift 6 choice but it requires macOS 15+. The package
/// targets macOS 14, so we fall back to `NSLock`. The lock is internal-only and never
/// shared, so `@unchecked Sendable` is safe.
private final class LockedCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0

    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return count
    }

    @discardableResult
    func increment() -> Int {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }
}

/// Actor-based counter for async retry tests.
private actor Counter {
    var count = 0

    func increment() -> Int {
        count += 1
        return count
    }
}
