//
//  Loggable.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Loggable

/// Defines a protocol for an object that logs messages.
public protocol Loggable {

    // MARK: - Debug

    /// Logs a message at the `debug` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Log() // `Log` conforms to the `Loggable` protocol.
    ///     logger.debug("A string")
    ///     logger.debug("A string with interpolation \(x)")
    ///
    /// - Parameter message: A string to log.
    func debug(_ message: String)

    /// Logs a message at the `debug` level along with a private message.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Log() // `Log` conforms to the `Loggable` protocol.
    ///     logger.debug("A string message", private: "A private message")
    ///
    ///     When developing prints:
    ///     "A string messsage: A private message"
    ///
    ///     In prod prints:
    ///     "A string messsage: <private>"
    ///
    /// - Parameter message: A string to log.
    /// - Parameter censored: A string that will be hidden in production builds.
    func debug(_ message: String, censored censoredMessage: String)

    // MARK: - Info

    /// Logs a message at the `info` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Log() // `Log` conforms to the `Loggable` protocol.
    ///     logger.info("A string")
    ///     logger.info("A string with interpolation \(x)")
    ///
    /// - Parameter message: A string to log.
    func info(_ message: String)

    /// Logs a message at the `info` level along with a private message.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Log() // `Log` conforms to the `Loggable` protocol.
    ///     logger.info("A string message", private: "A private message")
    ///
    ///     When developing prints:
    ///     "A string messsage: A private message"
    ///
    ///     In prod prints:
    ///     "A string messsage: <private>"
    ///
    /// - Parameter message: A string to log.
    /// - Parameter censored: A string that will be hidden in production builds.
    func info(_ message: String, censored censoredMessage: String)

    // MARK: - Error

    /// Logs a message at the `error` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Log() // `Log` conforms to the `Loggable` protocol.
    ///     logger.error("A string")
    ///     logger.error("A string with interpolation \(x)")
    ///
    /// - Parameter message: A string to log.
    func error(_ message: String)

    /// Logs a message at the `error` level along with a private message.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Log() // `Log` conforms to the `Loggable` protocol.
    ///     logger.error("A string message", private: "A private message")
    ///
    ///     When developing prints:
    ///     "A string messsage: A private message"
    ///
    ///     In prod prints:
    ///     "A string messsage: <private>"
    ///
    /// - Parameter message: A string to log.
    /// - Parameter censored: A string that will be hidden in production builds.
    func error(_ message: String, censored censoredMessage: String)

    // MARK: - Fault

    /// Logs a message at the `critical` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Log() // `Log` conforms to the `Loggable` protocol.
    ///     logger.fault("A string")
    ///     logger.fault("A string with interpolation \(x)")
    ///
    /// - Parameter message: A string to log.
    func fault(_ message: String)

    /// Logs a message at the `critical` level along with a private message.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Log() // `Log` conforms to the `Loggable` protocol.
    ///     logger.fault("A string message", private: "A private message")
    ///
    ///     When developing prints:
    ///     "A string messsage: A private message"
    ///
    ///     In prod prints:
    ///     "A string messsage: <private>"
    ///
    /// - Parameter message: A string to log.
    /// - Parameter censored: A string that will be hidden in production builds.
    func fault(_ message: String, censored censoredMessage: String)
}
