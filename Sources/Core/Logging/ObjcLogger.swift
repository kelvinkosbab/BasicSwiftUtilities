//
//  ObjcLogger.swift
//
//  Created by Kelvin Kosbab on 10/23/22.
//

import Foundation
import os.log

#if !os(macOS)

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
internal struct ObjcLogger : CoreLogger {
    
    private let osLog: OSLog
    
    init(subsystem: String, category: String) {
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    // MARK: - Debug
    
    func debug(_ message: String) {
        if #available(iOS 12.0, *) {
            os_log(.debug, log: self.osLog, "%{public}@", message)
        } else {
            os_log("%{public}@", log: self.osLog, type: .debug, message)
        }
    }
    
    func debug(_ message: String, private privateMessage: String) {
        if #available(iOS 12.0, *) {
            os_log(.debug, log: self.osLog, "%{public}@: %{private}@", message, privateMessage)
        } else {
            os_log("%{public}@: %{private}@", log: self.osLog, type: .debug, message, privateMessage)
        }
    }
    
    // MARK: - Info
    
    func info(_ message: String) {
        if #available(iOS 12.0, *) {
            os_log(.info, log: self.osLog, "%{public}@", message)
        } else {
            os_log("%{public}@", log: self.osLog, type: .info, message)
        }
    }
    
    func info(_ message: String, private privateMessage: String) {
        if #available(iOS 12.0, *) {
            os_log(.info, log: self.osLog, "%{public}@: %{private}@", message, privateMessage)
        } else {
            os_log("%{public}@: %{private}@", log: self.osLog, type: .info, message, privateMessage)
        }
    }
    
    // MARK: - Error
    
    func error(_ message: String) {
        if #available(iOS 12.0, *) {
            os_log(.error, log: self.osLog, "%{public}@", message)
        } else {
            os_log("%{public}@", log: self.osLog, type: .error, message)
        }
    }
    
    func error(_ message: String, private privateMessage: String) {
        if #available(iOS 12.0, *) {
            os_log(.error, log: self.osLog, "%{public}@: %{private}@", message, privateMessage)
        } else {
            os_log("%{public}@: %{private}@", log: self.osLog, type: .error, message, privateMessage)
        }
    }
    
    // MARK: - Fault
    
    func fault(_ message: String) {
        if #available(iOS 12.0, *) {
            os_log(.fault, log: self.osLog, "%{public}@", message)
        } else {
            os_log("%{public}@", log: self.osLog, type: .fault, message)
        }
    }
    
    func fault(_ message: String, private privateMessage: String) {
        if #available(iOS 12.0, *) {
            os_log(.fault, log: self.osLog, "%{public}@: %{private}@", message, privateMessage)
        } else {
            os_log("%{public}@: %{private}@", log: self.osLog, type: .fault, message, privateMessage)
        }
    }
}

#endif
