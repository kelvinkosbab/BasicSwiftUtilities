//
//  Logger.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Logger

public struct Logger: CoreLogger {
    
    private let logger: CoreLogger
    
    public init(subsystem: String, category: String) {
        #if !os(macOS)
        if #available(iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            self.init(logger: SwiftLogger(subsystem: subsystem, category: category))
        } else {
            self.init(logger: ObjcLogger(subsystem: subsystem, category: category))
        }
        #else
        self.init(logger: SwiftLogger(subsystem: subsystem, category: category))
        #endif
    }
    
    internal init(logger: CoreLogger) {
        self.logger = logger
    }
    
    // MARK: - Debug
    
    public func debug(_ message: String) {
        self.logger.debug("[Debug] \(message)")
    }
    
    public func debug(_ message: String, private privateMessage: String) {
        self.logger.debug("[Debug] \(message)", private: privateMessage)
    }
    
    // MARK: - Info
    
    public func info(_ message: String) {
        self.logger.info("[Info] \(message)")
    }
    
    public func info(_ message: String, private privateMessage: String) {
        self.logger.info("[Info] \(message)", private: privateMessage)
    }
    
    // MARK: - Error
    
    public func error(_ message: String) {
        self.logger.error("[Error] \(message)")
    }
    
    public func error(_ message: String, private privateMessage: String) {
        self.logger.error("[Error] \(message)", private: privateMessage)
    }
    
    // MARK: - Fault
    
    public func fault(_ message: String) {
        self.logger.fault("[Fault] \(message)")
    }
    
    public func fault(_ message: String, private privateMessage: String) {
        self.logger.fault("[Fault] \(message)", private: privateMessage)
    }
}
