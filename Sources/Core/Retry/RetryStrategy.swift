//
//  RetryStrategy.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - RetryStrategy

/// Defines various retry strategies.
public enum RetryStrategy {

    /// Exponential backoff strategy.
    ///
    /// - Parameter base: Initial delay amount in milliseconds.
    /// - Parameter exponent: Amount by which to multiple base by after each attempt.
    /// - Parameter limit: Maximum delay amount in milliseconds (not including jitter amount).
    /// - Parameter jitterRange: Maximum jitter amount in milliseconds, where `jitter == Double.randome(in: 0 ..< jitterRange)`.
    case exponential(base: Double, exponent: Double, limit: Double, jitterRange: Double)

    /// Linear backoff strategy.
    ///
    /// - Parameter base: Initial delay amount in milliseconds.
    /// - Parameter increment: Amojnt by which base will be incremented by (via addition) after each attempt.
    /// - Parameter limit: Maximum delay amount in milliseconds (not including jitter amount).
    /// - Parameter jitterRange: Maximum jitter amount in milliseconds, where `jitter == Double.randome(in: 0 ..< jitterRange)`.
    case linear(base: Double, increment: Double, limit: Double, jitterRange: Double)

    /// Constant backoff strategy.
    ///
    /// - Parameter base: Initial delay amount in milliseconds.
    /// - Parameter jitterRange: Maximum jitter amount in milliseconds, where `jitter == Double.randome(in: 0 ..< jitterRange)`.
    case constant(base: Double, jitterRange: Double)

    /// Custom backoff strategy.
    ///
    /// - Parameter strategy: Closure which returns the delay time in milliseconds.
    case custom(strategy: (_ attempts: UInt) -> Double)

    internal func calculateDelay(attempts: UInt) -> Double {
        switch self {
        case .exponential(let base, let exponent, let limit, let jitterRange):
            return min(limit, base * pow(exponent, Double(attempts - 1))) + Double.random(in: 0..<jitterRange)
        case .linear(let base, let increment, let limit, let jitterRange):
            return min(limit, base + increment * Double(attempts - 1)) + Double.random(in: 0..<jitterRange)
        case .constant(let base, let jitterRange):
            return base + Double.random(in: 0..<jitterRange)
        case .custom(let customStrategy):
            return customStrategy(attempts)
        }
    }
}
