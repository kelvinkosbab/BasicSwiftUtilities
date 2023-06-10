//
//  SwiftLogger.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import os.log

// MARK: - Swift os.Logger

/// An object that adds interpolated strings to the data store of the unified logging system via the
/// Swift `os.Logger`.
///
/// For more info see [Apple's documentation for `os.Logger`](https://developer.apple.com/documentation/os/logger).
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
public struct SwiftLogger : Loggable {
    
    private let logger: os.Logger
    
    /// Creates a custom logger for logging to a specific subsystem and category.
    ///
    /// - Parameter subsystem: Describes the module or app from which the log is being emitted from.
    /// - Parameter category: Describes a category specifying.
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
