//
//  ObjcOsLog.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import os.log

// MARK: - Objective-C OSLog

/// A log object that can be passed to logging functions in order to send messages to the logging
/// system via `os_log`.
///
/// For more info see [Apple's documentation for `OSLog`](https://developer.apple.com/documentation/os/oslog).
@available(iOS 10.0, watchOS 3.0, tvOS 10.0, *)
@available(macOS, unavailable, message: "Use `SwiftLogger` instead.")
@available(iOS, deprecated: 14.0, message: "Use `SwiftLogger` instead.")
@available(watchOS, deprecated: 7.0, message: "Use `SwiftLogger` instead.")
@available(tvOS, deprecated: 14.0, message: "Use `SwiftLogger` instead.")
public struct ObjcOsLog : Loggable {
    
    private let osLog: OSLog
    
    /// Creates a custom logger for logging to a specific subsystem and category.
    ///
    /// - Parameter subsystem: Describes the module or app from which the log is being emitted from.
    /// - Parameter category: Describes a category specifying.
    init(subsystem: String, category: String) {
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    // MARK: - Debug
    
    public func debug(_ message: String) {
        if #available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *) {
            os_log(
                .debug,
                log: self.osLog,
                "%{public}@", message
            )
        } else {
            os_log(
                "%{public}@",
                log: self.osLog,
                type: .debug,
                message
            )
        }
    }
    
    public func debug(_ message: String, censored censoredMessage: String) {
        if #available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *) {
            os_log(
                .debug,
                log: self.osLog,
                "%{public}@: %{private}@",
                message, censoredMessage
            )
        } else {
            os_log(
                "%{public}@: %{private}@",
                log: self.osLog,
                type: .debug,
                message, censoredMessage
            )
        }
    }
    
    // MARK: - Info
    
    public func info(_ message: String) {
        if #available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *) {
            os_log(
                .info,
                log: self.osLog,
                "%{public}@",
                message
            )
        } else {
            os_log(
                "%{public}@",
                log: self.osLog,
                type: .info,
                message
            )
        }
    }
    
    public func info(_ message: String, censored censoredMessage: String) {
        if #available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *) {
            os_log(
                .info,
                log: self.osLog,
                "%{public}@: %{private}@",
                message, censoredMessage
            )
        } else {
            os_log(
                "%{public}@: %{private}@",
                log: self.osLog,
                type: .info,
                message,
                censoredMessage
            )
        }
    }
    
    // MARK: - Error
    
    public func error(_ message: String) {
        if #available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *) {
            os_log(
                .error,
                log: self.osLog,
                "%{public}@",
                message
            )
        } else {
            os_log(
                "%{public}@",
                log: self.osLog,
                type: .error,
                message
            )
        }
    }
    
    public func error(_ message: String, censored censoredMessage: String) {
        if #available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *) {
            os_log(
                .error,
                log: self.osLog,
                "%{public}@: %{private}@",
                message, censoredMessage
            )
        } else {
            os_log(
                "%{public}@: %{private}@",
                log: self.osLog,
                type: .error,
                message, censoredMessage
            )
        }
    }
    
    // MARK: - Fault
    
    public func fault(_ message: String) {
        if #available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *) {
            os_log(
                .fault,
                log: self.osLog,
                "%{public}@",
                message
            )
        } else {
            os_log(
                "%{public}@",
                log: self.osLog,
                type: .fault,
                message
            )
        }
    }
    
    public func fault(_ message: String, censored censoredMessage: String) {
        if #available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *) {
            os_log(
                .fault,
                log: self.osLog,
                "%{public}@: %{private}@",
                message,
                censoredMessage
            )
        } else {
            os_log(
                "%{public}@: %{private}@",
                log: self.osLog,
                type: .fault,
                message,
                censoredMessage
            )
        }
    }
}
