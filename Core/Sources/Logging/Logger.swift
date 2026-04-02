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
/// `Logger` wraps Apple's `os.Logger` via ``SwiftLogger`` and formats log messages with
/// the log level and category for easy filtering in Console.app.
///
/// ```swift
/// let logger = Logger(subsystem: "com.myapp", category: "Networking")
/// logger.info("Request sent")
/// // Logs: "[Info] <Networking> Request sent"
/// ```
public struct Logger: Loggable, Sendable {

    private let logger: SwiftLogger
    private let category: String

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
        self.category = category
    }

    /// Creates a logger with a custom ``Loggable`` backend.
    ///
    /// - Note: Internal for unit testing use.
    ///
    /// - Parameter subsystem: Identifies the module or app emitting the log.
    /// - Parameter category: Describes the area of functionality being logged.
    /// - Parameter logger: The backing ``Loggable`` implementation to use.
    internal init(
        subsystem: String,
        category: String,
        logger: SwiftLogger
    ) {
        self.category = category
        self.logger = logger
    }

    // MARK: - Debug

    public func debug(_ message: String) {
        self.logger.debug("[Debug] <\(self.category)> \(message)")
    }

    public func debug(_ message: String, censored censoredMessage: String) {
        self.logger.debug("[Debug] <\(self.category)> \(message)", censored: censoredMessage)
    }

    // MARK: - Info

    public func info(_ message: String) {
        self.logger.info("[Info] <\(self.category)> \(message)")
    }

    public func info(_ message: String, censored censoredMessage: String) {
        self.logger.info("[Info] <\(self.category)> \(message)", censored: censoredMessage)
    }

    // MARK: - Error

    public func error(_ message: String) {
        self.logger.error("[Error] <\(self.category)> \(message)")
    }

    public func error(_ message: String, censored censoredMessage: String) {
        self.logger.error("[Error] <\(self.category)> \(message)", censored: censoredMessage)
    }

    // MARK: - Fault

    public func fault(_ message: String) {
        self.logger.fault("[Fault] <\(self.category)> \(message)")
    }

    public func fault(_ message: String, censored censoredMessage: String) {
        self.logger.fault("[Fault] <\(self.category)> \(message)", censored: censoredMessage)
    }
}
