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

    @Test("Succeeds on first attempt with zero retry attempts")
    func succeedsOnFirstAttempt() {
        let operation = retry(maxAttempts: 3, strategy: .constant(base: 0, jitterRange: 0)) {
            // succeeds immediately
        }
        let result = operation()
        if case .success(let attempts) = result {
            #expect(attempts == 0)
        } else {
            Issue.record("Expected success")
        }
    }

    @Test("Retries and eventually succeeds")
    func retriesAndSucceeds() {
        let counter = LockedCounter()
        let operation = retry(maxAttempts: 3, strategy: .constant(base: 0, jitterRange: 0)) {
            let count = counter.increment()
            if count < 3 {
                throw TestError.transient
            }
        }
        let result = operation()
        if case .success(let attempts) = result {
            #expect(attempts == 2)
        } else {
            Issue.record("Expected success after retries")
        }
    }

    @Test("Returns failure after exhausting all attempts")
    func failsAfterMaxAttempts() {
        let operation = retry(maxAttempts: 3, strategy: .constant(base: 0, jitterRange: 0)) {
            throw TestError.permanent
        }
        let result = operation()
        if case .failure = result {
            // expected
        } else {
            Issue.record("Expected failure")
        }
    }

    @Test("Short-circuits when retryIf returns false")
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
        if case .failure = result {
            // expected
        } else {
            Issue.record("Expected failure")
        }
    }

    // MARK: - Async Retry

    @Test("Async retry succeeds on first attempt")
    func asyncSucceedsOnFirstAttempt() async {
        let operation = asyncRetry(max: 3, strategy: .constant(base: 0, jitterRange: 0)) {
            return 42
        }
        let result = await operation()
        if case .success(let attempts, let value) = result {
            #expect(attempts == 0)
            #expect(value == 42)
        } else {
            Issue.record("Expected success")
        }
    }

    @Test("Async retry retries and eventually succeeds")
    func asyncRetriesAndSucceeds() async {
        let counter = Counter()
        let operation = asyncRetry(max: 3, strategy: .constant(base: 0, jitterRange: 0)) {
            let count = await counter.increment()
            if count < 3 {
                throw TestError.transient
            }
            return "done"
        }
        let result = await operation()
        if case .success(let attempts, let value) = result {
            #expect(attempts == 2)
            #expect(value == "done")
        } else {
            Issue.record("Expected success")
        }
    }

    @Test("Async retry fails after max attempts")
    func asyncFailsAfterMaxAttempts() async {
        let operation = asyncRetry(max: 2, strategy: .constant(base: 0, jitterRange: 0)) {
            throw TestError.permanent
            return 0
        }
        let result = await operation()
        if case .failure = result {
            // expected
        } else {
            Issue.record("Expected failure")
        }
    }

    // MARK: - RetryStrategy

    @Test("Exponential strategy calculates correct delays")
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

    @Test("Exponential strategy respects limit")
    func exponentialStrategyLimit() {
        let strategy = RetryStrategy.exponential(base: 100, exponent: 2, limit: 500, jitterRange: 0)
        let delay = strategy.calculateDelay(attempts: 4)
        #expect(delay == 500) // min(500, 800) = 500
    }

    @Test("Linear strategy calculates correct delays")
    func linearStrategy() {
        let strategy = RetryStrategy.linear(base: 100, increment: 50, limit: 1000, jitterRange: 0)
        let delay1 = strategy.calculateDelay(attempts: 1)
        let delay2 = strategy.calculateDelay(attempts: 2)
        let delay3 = strategy.calculateDelay(attempts: 3)
        #expect(delay1 == 100) // 100 + 50*0
        #expect(delay2 == 150) // 100 + 50*1
        #expect(delay3 == 200) // 100 + 50*2
    }

    @Test("Constant strategy returns same delay")
    func constantStrategy() {
        let strategy = RetryStrategy.constant(base: 200, jitterRange: 0)
        let delay1 = strategy.calculateDelay(attempts: 1)
        let delay2 = strategy.calculateDelay(attempts: 5)
        #expect(delay1 == 200)
        #expect(delay2 == 200)
    }

    @Test("Custom strategy uses provided closure")
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

// MARK: - Helpers

private enum TestError: Error, Equatable {
    case transient
    case permanent
}

/// Thread-safe counter for synchronous retry tests.
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
