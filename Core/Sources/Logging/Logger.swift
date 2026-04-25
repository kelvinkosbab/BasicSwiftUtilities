//
//  Logger.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Logger

/// An object that adds interpolated strings to the unified logging system for a specified
/// `subsystem` and `category`.
///
/// `Logger` is a thin convenience wrapper around ``SwiftLogger``. The level and category
/// are recorded as log metadata by the underlying `os.Logger`, so Console.app and the
/// `log` CLI can filter by them natively — no manual prefixing required.
///
/// ```swift
/// let logger = Logger(subsystem: "com.myapp", category: "Networking")
/// logger.info("Request sent")
/// // Console shows: "Info  Networking  Request sent"
/// ```
public struct Logger: Loggable, Sendable {

    private let logger: SwiftLogger

    /// Creates a logger for a specific subsystem and category.
    ///
    /// - Parameter subsystem: Identifies the module or app emitting the log.
    /// - Parameter category: Describes the area of functionality being logged.
    public init(
        subsystem: String,
        category: String
    ) {
        self.logger = SwiftLogger(
            subsystem: subsystem,
            category: category
        )
    }

    /// Creates a logger with a custom ``SwiftLogger`` backend.
    ///
    /// - Note: Internal for unit testing use.
    ///
    /// - Parameter subsystem: Identifies the module or app emitting the log.
    /// - Parameter category: Describes the area of functionality being logged.
    /// - Parameter logger: The backing ``SwiftLogger`` to use.
    internal init(
        subsystem: String,
        category: String,
        logger: SwiftLogger
    ) {
        self.logger = logger
    }

    // MARK: - Debug

    public func debug(_ message: String) {
        self.logger.debug(message)
    }

    public func debug(_ message: String, censored censoredMessage: String) {
        self.logger.debug(message, censored: censoredMessage)
    }

    // MARK: - Info

    public func info(_ message: String) {
        self.logger.info(message)
    }

    public func info(_ message: String, censored censoredMessage: String) {
        self.logger.info(message, censored: censoredMessage)
    }

    // MARK: - Error

    public func error(_ message: String) {
        self.logger.error(message)
    }

    public func error(_ message: String, censored censoredMessage: String) {
        self.logger.error(message, censored: censoredMessage)
    }

    // MARK: - Fault

    public func fault(_ message: String) {
        self.logger.fault(message)
    }

    public func fault(_ message: String, censored censoredMessage: String) {
        self.logger.fault(message, censored: censoredMessage)
    }
}
