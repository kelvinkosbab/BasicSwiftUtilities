//
//  Loggable.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Loggable

/// A protocol for objects that emit log messages at various severity levels.
///
/// Conforming types can log messages at `debug`, `info`, `error`, and `fault` levels.
/// Each level supports an optional censored variant where sensitive information is
/// automatically redacted in production builds.
///
/// ```swift
/// let logger: Loggable = Logger(subsystem: "com.myapp", category: "Auth")
/// logger.info("User logged in")
/// logger.info("User logged in", censored: "user@example.com")
/// ```
///
/// - Important: Strings passed to the plain (non-censored) methods are emitted with
///   `.public` privacy by the default ``SwiftLogger`` implementation. They will appear
///   in production logs in plaintext. Use the `censored:` variants for any sensitive
///   data — usernames, email addresses, tokens, or other PII.
public protocol Loggable: Sendable {

    // MARK: - Debug

    /// Logs a message at the `debug` level.
    ///
    /// Use debug-level messages for information useful only during active debugging.
    ///
    /// - Parameter message: The message to log.
    func debug(_ message: String)

    /// Logs a message at the `debug` level with a censored component.
    ///
    /// The censored message is visible in development but redacted in production builds.
    ///
    /// - Parameter message: The public portion of the message.
    /// - Parameter censored: The sensitive portion, hidden in production.
    func debug(_ message: String, censored censoredMessage: String)

    // MARK: - Info

    /// Logs a message at the `info` level.
    ///
    /// Use info-level messages for general operational information.
    ///
    /// - Parameter message: The message to log.
    func info(_ message: String)

    /// Logs a message at the `info` level with a censored component.
    ///
    /// The censored message is visible in development but redacted in production builds.
    ///
    /// - Parameter message: The public portion of the message.
    /// - Parameter censored: The sensitive portion, hidden in production.
    func info(_ message: String, censored censoredMessage: String)

    // MARK: - Error

    /// Logs a message at the `error` level.
    ///
    /// Use error-level messages for unexpected conditions that may be recoverable.
    ///
    /// - Parameter message: The message to log.
    func error(_ message: String)

    /// Logs a message at the `error` level with a censored component.
    ///
    /// The censored message is visible in development but redacted in production builds.
    ///
    /// - Parameter message: The public portion of the message.
    /// - Parameter censored: The sensitive portion, hidden in production.
    func error(_ message: String, censored censoredMessage: String)

    // MARK: - Fault

    /// Logs a message at the `fault` (critical) level.
    ///
    /// Use fault-level messages for conditions that indicate a bug in the program.
    ///
    /// - Parameter message: The message to log.
    func fault(_ message: String)

    /// Logs a message at the `fault` (critical) level with a censored component.
    ///
    /// The censored message is visible in development but redacted in production builds.
    ///
    /// - Parameter message: The public portion of the message.
    /// - Parameter censored: The sensitive portion, hidden in production.
    func fault(_ message: String, censored censoredMessage: String)
}
