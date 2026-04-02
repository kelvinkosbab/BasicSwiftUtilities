//
//  SwiftLogger.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import os.log

// MARK: - SwiftLogger

/// A ``Loggable`` implementation that logs via Apple's `os.Logger`.
///
/// Messages use privacy markers: public messages are always visible, while censored
/// messages are marked as `private` and automatically redacted in production.
///
/// For more info see [Apple's documentation for `os.Logger`](https://developer.apple.com/documentation/os/logger).
public struct SwiftLogger: Loggable, Sendable {

    private let logger: os.Logger

    /// Creates a logger for a specific subsystem and category.
    ///
    /// - Parameter subsystem: Identifies the module or app emitting the log.
    /// - Parameter category: Describes the area of functionality being logged.
    public init(subsystem: String, category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }

    // MARK: - Debug

    public func debug(_ message: String) {
        self.logger.debug("\(message, privacy: .public)")
    }

    public func debug(_ message: String, censored censoredMessage: String) {
        self.logger.debug("\(message, privacy: .public): \(censoredMessage, privacy: .private)")
    }

    // MARK: - Info

    public func info(_ message: String) {
        self.logger.info("\(message, privacy: .public)")
    }

    public func info(_ message: String, censored censoredMessage: String) {
        self.logger.info("\(message, privacy: .public): \(censoredMessage, privacy: .private)")
    }

    // MARK: - Error

    public func error(_ message: String) {
        self.logger.error("\(message, privacy: .public)")
    }

    public func error(_ message: String, censored censoredMessage: String) {
        self.logger.error("\(message, privacy: .public): \(censoredMessage, privacy: .private)")
    }

    // MARK: - Fault

    public func fault(_ message: String) {
        self.logger.fault("\(message, privacy: .public)")
    }

    public func fault(_ message: String, censored censoredMessage: String) {
        self.logger.fault("\(message, privacy: .public): \(censoredMessage, privacy: .private)")
    }
}
