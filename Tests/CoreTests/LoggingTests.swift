//
//  LoggingTests.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import XCTest
@testable import Core

// MARK: - Mocks

/// A logger that conforms to `CoreLogger` but does not override the private message APIs.
private class MockDefaultCoreLogger : CoreLogger {
    
    var debugLogs: [String] = []
    var infoLogs: [String] = []
    var errorLogs: [String] = []
    
    func debug(_ message: String) {
        self.debugLogs.append(message)
    }
    
    func info(_ message: String) {
        self.infoLogs.append(message)
    }
    
    func error(_ message: String) {
        self.errorLogs.append(message)
    }
}

/// A logger that conforms to `CoreLogger` but does override the private message APIs.
private class MockPrivateLogCoreLogger : CoreLogger {
    
    var debugLogs: [String] = []
    var infoLogs: [String] = []
    var errorLogs: [String] = []
    
    func debug(_ message: String) {
        self.debugLogs.append(message)
    }
    
    func info(_ message: String) {
        self.infoLogs.append(message)
    }
    
    func error(_ message: String) {
        self.errorLogs.append(message)
    }
    
    public func debug(_ message: String, private privateMessage: String) {
        self.debugLogs.append("\(message): \(privateMessage)")
    }
    
    public func info(_ message: String, private privateMessage: String) {
        self.infoLogs.append("\(message): \(privateMessage)")
    }
    
    public func error(_ message: String, private privateMessage: String) {
        self.errorLogs.append("\(message): \(privateMessage)")
    }
}

// MARK: - Tests

final class DefaultLoggerTests: XCTestCase {
    
    /// Default logger should log a `debug` message correctly.
    ///
    /// - Expect a logged string to be logged at the `debug` level and log to equal the input.
    func testDefaultLoggerLogsDebug() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        logger.debug(someString)
        XCTAssert(mockLogger.debugLogs.count == 1)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.debugLogs[0] == "[Debug] \(someString)")
    }
    
    /// Default logger should log an `info` message correctly.
    ///
    /// - Expect a logged string to be logged at the `info` level and log to equal the input.
    func testDefaultLoggerLogsInfo() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        logger.info(someString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 1)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.infoLogs[0] == "[Info] \(someString)")
    }
    
    /// Default logger should log an `error` message correctly.
    ///
    /// - Expect a logged string to be logged at the `error` level and log to equal the input.
    func testDefaultLoggerLogsError() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        logger.error(someString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 1)
        XCTAssert(mockLogger.errorLogs[0] == "[Error] \(someString)")
    }
    
    /// Default logger should log a private `debug` message correctly.
    ///
    /// - Expect a logged string to be logged at the `error` level and log to equal the input minus the private message.
    func testDefaultLoggerLogsPrivateDebug() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.debug(someString, private: somePrivateString)
        XCTAssert(mockLogger.debugLogs.count == 1)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.debugLogs[0] == "[Debug] \(someString): <private>")
    }
    
    /// Default logger should log a private `info` message correctly.
    ///
    /// - Expect a logged string to be logged at the `error` level and log to equal the input minus the private message.
    func testDefaultLoggerLogsPrivateInfo() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.info(someString, private: somePrivateString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 1)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.infoLogs[0] == "[Info] \(someString): <private>")
    }
    
    /// Default logger should log a private `error` message correctly.
    ///
    /// - Expect a logged string to be logged at the `error` level and log to equal the input minus the private message.
    func testDefaultLoggerLogsPrivateError() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.error(someString, private: somePrivateString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 1)
        XCTAssert(mockLogger.errorLogs[0] == "[Error] \(someString): <private>")
    }
}

final class PrivateLoggerTests: XCTestCase {
    
    /// Default logger should log a `debug` message correctly.
    ///
    /// - Expect a logged string to be logged at the `debug` level and log to equal the input.
    func testDefaultLoggerLogsDebug() {
        let mockLogger = MockPrivateLogCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        logger.debug(someString)
        XCTAssert(mockLogger.debugLogs.count == 1)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.debugLogs[0] == "[Debug] \(someString)")
    }
    
    /// Default logger should log an `info` message correctly.
    ///
    /// - Expect a logged string to be logged at the `info` level and log to equal the input.
    func testDefaultLoggerLogsInfo() {
        let mockLogger = MockPrivateLogCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        logger.info(someString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 1)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.infoLogs[0] == "[Info] \(someString)")
    }
    
    /// Default logger should log an `error` message correctly.
    ///
    /// - Expect a logged string to be logged at the `error` level and log to equal the input.
    func testDefaultLoggerLogsError() {
        let mockLogger = MockPrivateLogCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        logger.error(someString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 1)
        XCTAssert(mockLogger.errorLogs[0] == "[Error] \(someString)")
    }
    
    /// Default logger should log a private `debug` message correctly.
    ///
    /// - Expect a logged string to be logged at the `error` level and log to equal the input and the private message.
    func testDefaultLoggerLogsPrivateDebug() {
        let mockLogger = MockPrivateLogCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.debug(someString, private: somePrivateString)
        XCTAssert(mockLogger.debugLogs.count == 1)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.debugLogs[0] == "[Debug] \(someString): \(somePrivateString)")
    }
    
    /// Default logger should log a private `info` message correctly.
    ///
    /// - Expect a logged string to be logged at the `error` level and log to equal the input and the private message.
    func testDefaultLoggerLogsPrivateInfo() {
        let mockLogger = MockPrivateLogCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.info(someString, private: somePrivateString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 1)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.infoLogs[0] == "[Info] \(someString): \(somePrivateString)")
    }
    
    /// Default logger should log a private `error` message correctly.
    ///
    /// - Expect a logged string to be logged at the `error` level and log to equal the input and the private message.
    func testDefaultLoggerLogsPrivateError() {
        let mockLogger = MockPrivateLogCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.error(someString, private: somePrivateString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 1)
        XCTAssert(mockLogger.errorLogs[0] == "[Error] \(someString): \(somePrivateString)")
    }
}
