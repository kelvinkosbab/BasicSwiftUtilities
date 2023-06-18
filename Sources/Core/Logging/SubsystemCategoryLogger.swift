//
//  SubsystemCategoryLogger.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - SubsystemCategoryLogger

/// An object that adds interpolated strings to the data store of the unified logging system for a
/// specified `subsystem` and `category`.
///
/// This object either wraps `os.Logger` or `os_log` depending on Platform and OS version.
public struct SubsystemCategoryLogger : Loggable {
    
    private let logger: Loggable

    /// Creates a custom logger for logging to a specific subsystem and category.
    ///
    /// - Parameter subsystem: Describes the module or app from which the log is being emitted from.
    /// - Parameter category: Describes a category specifying the specific action that is happening.
    public init(
        subsystem: String,
        category: String
    ) {
        #if !os(macOS)
        if #available(iOS 14.0, watchOS 7.0, tvOS 14.0, macOS 11, *) {
            self.init(logger: SwiftLogger(
                subsystem: subsystem,
                category: category
            ))
        } else {
            self.init(logger: LoggableOSLog(
                subsystem: subsystem,
                category: category
            ))
        }
        #else
        self.init(logger: SwiftLogger(
            subsystem: subsystem,
            category: category
        ))
        #endif
    }
    
    /// Creates a custom logger for logging to the provided logger.
    ///
    /// - Note: Internal for unit testing use.
    ///
    /// - Parameter logger: object which will log the messages.
    internal init(logger: Loggable) {
        self.logger = logger
    }
    
    // MARK: - Debug
    
    public func debug(_ message: String) {
        self.logger.debug("[Debug] \(message)")
    }
    
    public func debug(_ message: String, censored censoredMessage: String) {
        self.logger.debug("[Debug] \(message)", censored: censoredMessage)
    }
    
    // MARK: - Info
    
    public func info(_ message: String) {
        self.logger.info("[Info] \(message)")
    }
    
    public func info(_ message: String, censored censoredMessage: String) {
        self.logger.info("[Info] \(message)", censored: censoredMessage)
    }
    
    // MARK: - Error
    
    public func error(_ message: String) {
        self.logger.error("[Error] \(message)")
    }
    
    public func error(_ message: String, censored censoredMessage: String) {
        self.logger.error("[Error] \(message)", censored: censoredMessage)
    }
    
    // MARK: - Fault
    
    public func fault(_ message: String) {
        self.logger.fault("[Fault] \(message)")
    }
    
    public func fault(_ message: String, censored censoredMessage: String) {
        self.logger.fault("[Fault] \(message)", censored: censoredMessage)
    }
}
