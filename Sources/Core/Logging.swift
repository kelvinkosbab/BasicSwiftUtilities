//
//  Logging.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation
import os.log

// MARK: - CoreLogger

public protocol CoreLogger {
    
    /// Logs a message at the `debug` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.debug("A string")
    ///     logger.debug("A string interpolation \(x)")
    ///
    /// - Parameter message: A string.
    func debug(_ message: String)
    
    /// Logs a message at the `debug` level along with a private message.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.debug("A string message", private: "A private message")
    ///
    ///     When developing prints:
    ///     "A string messsage: A private message"
    ///
    ///     In prod prints:
    ///     "A string messsage: <private>"
    ///
    /// - Parameter message: A string.
    /// - Parameter privateMessage: A string that will be hidden in prod builds.
    func debug(_ message: String, private privateMessage: String)
    
    /// Logs a message at the `info` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.debug("A string")
    ///     logger.debug("A string interpolation \(x)")
    ///
    /// - Parameter message: A string.
    func info(_ message: String)
    
    /// Logs a message at the `info` level along with a private message.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.info("A string message", private: "A private message")
    ///
    ///     When developing prints:
    ///     "A string messsage: A private message"
    ///
    ///     In prod prints:
    ///     "A string messsage: <private>"
    ///
    /// - Parameter message: A string.
    /// - Parameter privateMessage: A string that will be hidden in prod builds.
    func info(_ message: String, private privateMessage: String)
    
    /// Logs a message at the `error` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.debug("A string")
    ///     logger.debug("A string interpolation \(x)")
    ///
    /// - Parameter message: A string.
    func error(_ message: String)
    
    /// Logs a message at the `error` level along with a private message.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.error("A string message", private: "A private message")
    ///
    ///     When developing prints:
    ///     "A string messsage: A private message"
    ///
    ///     In prod prints:
    ///     "A string messsage: <private>"
    ///
    /// - Parameter message: A string.
    /// - Parameter privateMessage: A string that will be hidden in prod builds.
    func error(_ message: String, private privateMessage: String)
}

public extension CoreLogger {
    
    /// Logs a message at the `debug` level.
    ///
    /// - Warning: By default do not log the `privateMessage`.
    ///
    /// - Parameter message: A string.
    /// - Parameter privateMessage: A string that will not be logged.
    func debug(_ message: String, private privateMessage: String) {
        self.debug("\(message): <private>")
    }
    
    /// Logs a message at the `info` level.
    ///
    /// - Warning: By default do not log the `privateMessage`.
    ///
    /// - Parameter message: A string.
    /// - Parameter privateMessage: A string that will not be logged.
    func info(_ message: String, private privateMessage: String) {
        self.info("\(message): <private>")
    }
    
    /// Logs a message at the `error` level.
    ///
    /// - Warning: By default do not log the `privateMessage`.
    ///
    /// - Parameter message: A string.
    /// - Parameter privateMessage: A string that will not be logged.
    func error(_ message: String, private privateMessage: String) {
        self.error("\(message): <private>")
    }
}

// MARK: - Logger

public struct Logger: CoreLogger {
    
    private let logger: CoreLogger
    
    public init(subsystem: String, category: String) {
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            self.init(logger: SwiftLogger(subsystem: subsystem, category: category))
        } else {
            self.init(logger: ObjcLogger(subsystem: subsystem, category: category))
        }
    }
    
    internal init(logger: CoreLogger) {
        self.logger = logger
    }
    
    public func debug(_ message: String) {
        self.logger.debug("[Debug] \(message)")
    }
    
    public func info(_ message: String) {
        self.logger.info("[Info] \(message)")
    }
    
    public func error(_ message: String) {
        self.logger.error("[Error] \(message)")
    }
    
    public func debug(_ message: String, private privateMessage: String) {
        self.logger.debug("[Debug] \(message)", private: privateMessage)
    }
    
    public func info(_ message: String, private privateMessage: String) {
        self.logger.info("[Info] \(message)", private: privateMessage)
    }
    
    public func error(_ message: String, private privateMessage: String) {
        self.logger.error("[Error] \(message)", private: privateMessage)
    }
}

// MARK: - Objective-C OSLog

/// A log object that can be passed to logging functions in order to send messages to the logging system.
///
/// - Note: In macOS 11 and later, use the Logger structure to generate log messages.
///
/// For more info see https://developer.apple.com/documentation/os/oslog.
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
@available(macOS, obsoleted: 11.0, message: "Use `SwiftLogger` instead.")
@available(iOS, obsoleted: 14.0, message: "Use `SwiftLogger` instead.")
@available(watchOS, obsoleted: 7.0, message: "Use `SwiftLogger` instead.")
@available(tvOS, obsoleted: 14.0, message: "Use `SwiftLogger` instead.")
private struct ObjcLogger : CoreLogger {
    
    private let osLog: OSLog
    
    public init(subsystem: String, category: String) {
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    func debug(_ message: String) {
        if #available(iOS 12.0, *) {
            os_log(.debug, log: self.osLog, "%{public}@", message)
        } else {
            os_log("%{public}@", log: self.osLog, type: .debug, message)
        }
    }
    
    func info(_ message: String) {
        if #available(iOS 12.0, *) {
            os_log(.info, log: self.osLog, "%{public}@", message)
        } else {
            os_log("%{public}@", log: self.osLog, type: .info, message)
        }
    }
    
    func error(_ message: String) {
        if #available(iOS 12.0, *) {
            os_log(.error, log: self.osLog, "%{public}@", message)
        } else {
            os_log("%{public}@", log: self.osLog, type: .error, message)
        }
    }
    
    func debug(_ message: String, private privateMessage: String) {
        if #available(iOS 12.0, *) {
            os_log(.debug, log: self.osLog, "%{public}@: %{private}@", message, privateMessage)
        } else {
            os_log("%{public}@: %{private}@", log: self.osLog, type: .debug, message, privateMessage)
        }
    }
    
    func info(_ message: String, private privateMessage: String) {
        if #available(iOS 12.0, *) {
            os_log(.info, log: self.osLog, "%{public}@: %{private}@", message, privateMessage)
        } else {
            os_log("%{public}@: %{private}@", log: self.osLog, type: .info, message, privateMessage)
        }
    }
    
    func error(_ message: String, private privateMessage: String) {
        if #available(iOS 12.0, *) {
            os_log(.error, log: self.osLog, "%{public}@: %{private}@", message, privateMessage)
        } else {
            os_log("%{public}@: %{private}@", log: self.osLog, type: .error, message, privateMessage)
        }
    }
}

// MARK: - Swift os.Logger

/// An object that adds interpolated strings to the data store of the unified logging system.
///
/// For more info see https://developer.apple.com/documentation/os/logger.
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
private struct SwiftLogger : CoreLogger {
    
    private let logger: os.Logger
    
    public init(subsystem: String, category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }
    
    func debug(_ message: String) {
        self.logger.debug("\(message, privacy: .public)")
    }
    
    func info(_ message: String) {
        self.logger.info("\(message, privacy: .public)")
    }
    
    func error(_ message: String) {
        self.logger.error("\(message, privacy: .public)")
    }
    
    func debug(_ message: String, private privateMessage: String) {
        self.logger.debug("\(message, privacy: .public): \(privateMessage, privacy: .private)")
    }
    
    func info(_ message: String, private privateMessage: String) {
        self.logger.info("\(message, privacy: .public): \(privateMessage, privacy: .private)")
    }
    
    func error(_ message: String, private privateMessage: String) {
        self.logger.error("\(message, privacy: .public): \(privateMessage, privacy: .private)")
    }
}
