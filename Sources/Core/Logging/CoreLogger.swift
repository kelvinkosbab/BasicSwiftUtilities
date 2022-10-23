//
//  CoreLogger.swift
//
//  Created by Kelvin Kosbab on 10/23/22.
//

import Foundation

// MARK: - CoreLogger

public protocol CoreLogger {
    
    // MARK: - Debug
    
    /// Logs a message at the `debug` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.debug("A string")
    ///     logger.debug("A string with interpolation \(x)")
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
    
    // MARK: - Info
    
    /// Logs a message at the `info` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.info("A string")
    ///     logger.info("A string with interpolation \(x)")
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
    
    // MARK: - Error
    
    /// Logs a message at the `error` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.error("A string")
    ///     logger.error("A string with interpolation \(x)")
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
    
    // MARK: - Fault
    
    /// Logs a message at the `critical` level.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.critical("A string")
    ///     logger.critical("A string with interpolation \(x)")
    ///
    /// - Parameter message: A string.
    func fault(_ message: String)
    
    /// Logs a message at the `critical` level along with a private message.
    ///
    /// Examples
    /// ========
    ///
    ///     let logger = Logger()
    ///     logger.critical("A string message", private: "A private message")
    ///
    ///     When developing prints:
    ///     "A string messsage: A private message"
    ///
    ///     In prod prints:
    ///     "A string messsage: <private>"
    ///
    /// - Parameter message: A string.
    /// - Parameter privateMessage: A string that will be hidden in prod builds.
    func fault(_ message: String, private privateMessage: String)
}
