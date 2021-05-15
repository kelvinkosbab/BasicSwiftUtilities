//
//  Logging.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation
import os.log

// MARK: - CoreLogger

public protocol CoreLogger {
    
    /// Creates a custom logger for logging to a specific subsystem and category.
    init(subsystem: String, category: String)
    
    /// Logs a string interpolation at the `debug` level.
    ///
    /// Values that can be interpolated include signed and unsigned Swift integers, Floats,
    /// Doubles, Bools, Strings, NSObjects, UnsafeRaw(Buffer)Pointers, values conforming to
    /// `CustomStringConvertible` like Arrays and Dictionaries, and metatypes like
    /// `type(of: c)`, `Int.self`.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.debug("A string interpolation \(x)")
    ///
    /// Formatting Interpolated Expressions and Specifying Privacy
    /// ==========================================================
    ///
    /// Formatting and privacy options for the interpolated values can be passed as arguments
    /// to the interpolations. These are optional arguments. When not specified, they will be set to their
    /// default values.
    ///
    ///     logger.debug("An unsigned integer \(x, format: .hex, align: .right(columns: 10))")
    ///     logger.debug("An unsigned integer \(x, privacy: .private)")
    ///
    /// - Warning: Do not explicity create OSLogMessage. Instead pass a string interpolation.
    ///
    /// - Parameter message: A string interpolation.
    func debug(_ message: String)
    
    /// Logs a string interpolation at the `info` level.
    ///
    /// Values that can be interpolated include signed and unsigned Swift integers, Floats,
    /// Doubles, Bools, Strings, NSObjects, UnsafeRaw(Buffer)Pointers, values conforming to
    /// `CustomStringConvertible` like Arrays and Dictionaries, and metatypes like
    /// `type(of: c)`, `Int.self`.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.info("A string interpolation \(x)")
    ///
    /// Formatting Interpolated Expressions and Specifying Privacy
    /// ==========================================================
    ///
    /// Formatting and privacy options for the interpolated values can be passed as arguments
    /// to the interpolations. These are optional arguments. When not specified, they will be set to their
    /// default values.
    ///
    ///     logger.info("An unsigned integer \(x, format: .hex, align: .right(columns: 10))")
    ///     logger.info("An unsigned integer \(x, privacy: .private)")
    ///
    /// - Warning: Do not explicity create OSLogMessage. Instead pass a string interpolation.
    ///
    /// - Parameter message: A string interpolation.
    func info(_ message: String)
    
    /// Logs a string interpolation at the `error` level.
    ///
    /// Values that can be interpolated include signed and unsigned Swift integers, Floats,
    /// Doubles, Bools, Strings, NSObjects, UnsafeRaw(Buffer)Pointers, values conforming to
    /// `CustomStringConvertible` like Arrays and Dictionaries, and metatypes like
    /// `type(of: c)`, `Int.self`.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.error("A string interpolation \(x)")
    ///
    /// Formatting Interpolated Expressions and Specifying Privacy
    /// ==========================================================
    ///
    /// Formatting and privacy options for the interpolated values can be passed as arguments
    /// to the interpolations. These are optional arguments. When not specified, they will be set to their
    /// default values.
    ///
    ///     logger.error("An unsigned integer \(x, format: .hex, align: .right(columns: 10))")
    ///     logger.error("An unsigned integer \(x, privacy: .private)")
    ///
    /// - Warning: Do not explicity create OSLogMessage. Instead pass a string interpolation.
    ///
    /// - Parameter message: A string interpolation.
    func error(_ message: String)
}

public extension CoreLogger {
    
    init(category: String) {
        self.init(subsystem: "com.kozinga.TallyBok", category: category)
    }
}

// MARK: - Logger

public struct Logger: CoreLogger {
    
    private let logger: CoreLogger
    private let logPrivateMessages: Bool
    
    /// Creates a custom logger for logging to a specific subsystem and category.
    public init(subsystem: String, category: String) {
        
        let logPrivateMessages: Bool
        #if DEBUG
        
        // Determine if being debugged by Xcode
        var info = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        logPrivateMessages = (info.kp_proc.p_flag & P_TRACED) != 0
        
        #else
        
        logPrivateMessages = false
        
        #endif
        
        self.init(subsystem: subsystem, category: category, logPrivateMessages: logPrivateMessages)
    }
    
    internal init(subsystem: String, category: String, logPrivateMessages: Bool) {
        if #available(iOS 14, OSX 11.0, *) {
            self.logger = SwiftLogger(subsystem: subsystem, category: category)
        } else {
            self.logger = ObjcLogger(subsystem: subsystem, category: category)
        }
        self.logPrivateMessages = logPrivateMessages
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
    
    public func debug(_ message: String, privateMessage: String) {
        if self.logPrivateMessages {
            self.debug("\(message): \(privateMessage)")
        } else {
            self.debug(message)
        }
    }
    
    public func info(_ message: String, privateMessage: String) {
        if self.logPrivateMessages {
            self.info("\(message): \(privateMessage)")
        } else {
            self.info(message)
        }
    }
    
    public func error(_ message: String, privateMessage: String) {
        if self.logPrivateMessages {
            self.error("\(message): \(privateMessage)")
        } else {
            self.error(message)
        }
    }
}

// MARK: - Objective-C OSLog

@available(iOS 10.0, OSX 10.14, *)
private struct ObjcLogger : CoreLogger {
    
    private let osLog: OSLog
    
    /// Creates a custom logger for logging to a specific subsystem and category.
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
}

// MARK: - Swift os.Logger

@available(iOS 14.0, OSX 11.0, *)
private struct SwiftLogger : CoreLogger {
    
    private let logger: os.Logger
    
    /// Creates a custom logger for logging to a specific subsystem and category.
    public init(subsystem: String, category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }
    
    func debug(_ message: String) {
        self.logger.debug("\(message)")
    }
    
    func info(_ message: String) {
        self.logger.info("\(message)")
    }
    
    func error(_ message: String) {
        self.logger.error("\(message)")
    }
}
