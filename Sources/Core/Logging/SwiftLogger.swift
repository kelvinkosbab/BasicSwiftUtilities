//
//  SwiftLogger.swift
//
//  Created by Kelvin Kosbab on 10/23/22.
//

import Foundation
import os.log

// MARK: - Swift os.Logger

/// An object that adds interpolated strings to the data store of the unified logging system.
///
/// For more info see https://developer.apple.com/documentation/os/logger.
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
internal struct SwiftLogger : CoreLogger {
    
    private let logger: os.Logger
    
    public init(subsystem: String, category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }
    
    // MARK: - Debug
    
    func debug(_ message: String) {
        self.logger.debug("\(message, privacy: .public)")
    }
    
    func debug(_ message: String, private privateMessage: String) {
        self.logger.debug("\(message, privacy: .public): \(privateMessage, privacy: .private)")
    }
    
    // MARK: - Info
    
    func info(_ message: String) {
        self.logger.info("\(message, privacy: .public)")
    }
    
    func info(_ message: String, private privateMessage: String) {
        self.logger.info("\(message, privacy: .public): \(privateMessage, privacy: .private)")
    }
    
    // MARK: - Error
    
    func error(_ message: String) {
        self.logger.error("\(message, privacy: .public)")
    }
    
    func error(_ message: String, private privateMessage: String) {
        self.logger.error("\(message, privacy: .public): \(privateMessage, privacy: .private)")
    }
    
    // MARK: - Fault
    
    func fault(_ message: String) {
        self.logger.fault("\(message, privacy: .public)")
    }
    
    func fault(_ message: String, private privateMessage: String) {
        self.logger.fault("\(message, privacy: .public): \(privateMessage, privacy: .private)")
    }
}
