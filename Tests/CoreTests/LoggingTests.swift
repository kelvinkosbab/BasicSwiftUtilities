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
    var faultLogs: [String] = []
    
    func debug(_ message: String) {
        self.debugLogs.append(message)
    }
    
    func debug(_ message: String, private privateMessage: String) {
        self.debugLogs.append("\(message):\(privateMessage)")
    }
    
    func info(_ message: String) {
        self.infoLogs.append(message)
    }
    
    func info(_ message: String, private privateMessage: String) {
        self.infoLogs.append("\(message):\(privateMessage)")
    }
    
    func error(_ message: String) {
        self.errorLogs.append(message)
    }
    
    func error(_ message: String, private privateMessage: String) {
        self.errorLogs.append("\(message):\(privateMessage)")
    }
    
    func fault(_ message: String) {
        self.faultLogs.append(message)
    }
    
    func fault(_ message: String, private privateMessage: String) {
        self.faultLogs.append("\(message):\(privateMessage)")
    }
}

// MARK: - Tests

final class LoggerTests: XCTestCase {
    
    // MARK: - Debug Log Tests
    
    /// Default logger should log a `debug` message correctly.
    ///
    /// - Expect a logged string to be logged at the `debug` level and log to equal the input.
    func testLoggerLogsDebug() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        logger.debug(someString)
        XCTAssert(mockLogger.debugLogs.count == 1)
        XCTAssert(mockLogger.debugLogs[0] == "[Debug] \(someString)")
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.faultLogs.count == 0)
    }
    
    /// Default logger should log a `debug` message with a private message correctly.
    ///
    /// - Expect a logged string to be logged at the `debug` level and log to equal the input.
    func testLoggerLogsDebugWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.debug(someString, private: somePrivateString)
        XCTAssert(mockLogger.debugLogs.count == 1)
        XCTAssert(mockLogger.debugLogs[0] == "[Debug] \(someString):\(somePrivateString)")
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.faultLogs.count == 0)
    }
    
    // MARK: - Info Log Tests
    
    /// Default logger should log a `info` message correctly.
    ///
    /// - Expect a logged string to be logged at the `info` level and log to equal the input.
    func testLoggerLogsInfo() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        logger.info(someString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 1)
        XCTAssert(mockLogger.infoLogs[0] == "[Info] \(someString)")
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.faultLogs.count == 0)
    }
    
    /// Default logger should log a `info` message with a private message correctly.
    ///
    /// - Expect a logged string to be logged at the `info` level and log to equal the input.
    func testLoggerLogsInfoWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.info(someString, private: somePrivateString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 1)
        XCTAssert(mockLogger.infoLogs[0] == "[Info] \(someString):\(somePrivateString)")
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.faultLogs.count == 0)
    }
    
    // MARK: - Error Log Tests
    
    /// Default logger should log a `error` message correctly.
    ///
    /// - Expect a logged string to be logged at the `error` level and log to equal the input.
    func testLoggerLogsError() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        logger.error(someString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 1)
        XCTAssert(mockLogger.errorLogs[0] == "[Error] \(someString)")
        XCTAssert(mockLogger.faultLogs.count == 0)
    }
    
    /// Default logger should log a `error` message with a private message correctly.
    ///
    /// - Expect a logged string to be logged at the `error` level and log to equal the input.
    func testLoggerLogsErrorWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.error(someString, private: somePrivateString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 1)
        XCTAssert(mockLogger.errorLogs[0] == "[Error] \(someString):\(somePrivateString)")
        XCTAssert(mockLogger.faultLogs.count == 0)
    }
    
    // MARK: - Fault Log Tests
    
    /// Default logger should log a `fault` message correctly.
    ///
    /// - Expect a logged string to be logged at the `fault` level and log to equal the input.
    func testLoggerLogsFault() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        logger.fault(someString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.faultLogs.count == 1)
        XCTAssert(mockLogger.faultLogs[0] == "[Fault] \(someString)")
    }
    
    /// Default logger should log a `fault` message with a private message correctly.
    ///
    /// - Expect a logged string to be logged at the `fault` level and log to equal the input.
    func testLoggerLogsFaultWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = Logger(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.fault(someString, private: somePrivateString)
        XCTAssert(mockLogger.debugLogs.count == 0)
        XCTAssert(mockLogger.infoLogs.count == 0)
        XCTAssert(mockLogger.errorLogs.count == 0)
        XCTAssert(mockLogger.faultLogs.count == 1)
        XCTAssert(mockLogger.faultLogs[0] == "[Fault] \(someString):\(somePrivateString)")
    }
}
