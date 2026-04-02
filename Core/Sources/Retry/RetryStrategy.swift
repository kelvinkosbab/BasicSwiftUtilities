//
//  RetryStrategy.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - RetryStrategy

/// Defines the delay strategy between retry attempts.
///
/// Each strategy computes a delay (in milliseconds) based on the current attempt number.
///
/// ```swift
/// let strategy: RetryStrategy = .exponential(
///     base: 100,
///     exponent: 2,
///     limit: 5000,
///     jitterRange: 50
/// )
/// ```
public enum RetryStrategy: Sendable {

    /// Exponential backoff: delay = min(limit, base * exponent^(attempts-1)) + jitter.
    ///
    /// - Parameter base: Initial delay in milliseconds.
    /// - Parameter exponent: Multiplier applied after each attempt.
    /// - Parameter limit: Maximum delay in milliseconds (excluding jitter).
    /// - Parameter jitterRange: Random jitter added, in range `0..<jitterRange` milliseconds.
    case exponential(base: Double, exponent: Double, limit: Double, jitterRange: Double)

    /// Linear backoff: delay = min(limit, base + increment * (attempts-1)) + jitter.
    ///
    /// - Parameter base: Initial delay in milliseconds.
    /// - Parameter increment: Amount added after each attempt.
    /// - Parameter limit: Maximum delay in milliseconds (excluding jitter).
    /// - Parameter jitterRange: Random jitter added, in range `0..<jitterRange` milliseconds.
    case linear(base: Double, increment: Double, limit: Double, jitterRange: Double)

    /// Constant backoff: delay = base + jitter.
    ///
    /// - Parameter base: Constant delay in milliseconds.
    /// - Parameter jitterRange: Random jitter added, in range `0..<jitterRange` milliseconds.
    case constant(base: Double, jitterRange: Double)

    /// Custom backoff using a caller-provided closure.
    ///
    /// - Parameter strategy: A closure that receives the attempt number and returns delay in milliseconds.
    case custom(strategy: @Sendable (_ attempts: UInt) -> Double)

    /// Calculates the delay in milliseconds for the given attempt number.
    ///
    /// - Parameter attempts: The current attempt number (1-based).
    /// - Returns: The delay in milliseconds before the next retry.
    internal func calculateDelay(attempts: UInt) -> Double {
        switch self {
        case .exponential(let base, let exponent, let limit, let jitterRange):
            return min(limit, base * pow(exponent, Double(attempts - 1))) + jitter(jitterRange)
        case .linear(let base, let increment, let limit, let jitterRange):
            return min(limit, base + increment * Double(attempts - 1)) + jitter(jitterRange)
        case .constant(let base, let jitterRange):
            return base + jitter(jitterRange)
        case .custom(let customStrategy):
            return customStrategy(attempts)
        }
    }

    private func jitter(_ range: Double) -> Double {
        range > 0 ? Double.random(in: 0..<range) : 0
    }
}
