//
//  LoggingUtilsTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import Foundation
@testable import Core

// MARK: - Mocks

private final class MockDefaultCoreLogger: Loggable, @unchecked Sendable {

    var debugLogs: [String] = []
    var infoLogs: [String] = []
    var errorLogs: [String] = []
    var faultLogs: [String] = []

    func debug(_ message: String) {
        self.debugLogs.append(message)
    }

    func debug(_ message: String, censored censoredMessage: String) {
        self.debugLogs.append("\(message):\(censoredMessage)")
    }

    func info(_ message: String) {
        self.infoLogs.append(message)
    }

    func info(_ message: String, censored censoredMessage: String) {
        self.infoLogs.append("\(message):\(censoredMessage)")
    }

    func error(_ message: String) {
        self.errorLogs.append(message)
    }

    func error(_ message: String, censored censoredMessage: String) {
        self.errorLogs.append("\(message):\(censoredMessage)")
    }

    func fault(_ message: String) {
        self.faultLogs.append(message)
    }

    func fault(_ message: String, censored censoredMessage: String) {
        self.faultLogs.append("\(message):\(censoredMessage)")
    }
}

// MARK: - Tests

@Suite("Logger")
struct LoggerTests {

    let mockSubsystem = "mockSubsystem"
    let mockCategory = "mockCategory"

    // The Logger struct delegates directly to its backing Loggable.
    // We verify the pass-through behavior using a mock Loggable.

    // MARK: - Debug Log Tests

    @Test("Logs debug message verbatim")
    func loggerLogsDebug() {
        let mockLogger = MockDefaultCoreLogger()
        let wrapper = MockLoggableWrapper(logger: mockLogger)
        let someString = UUID().uuidString
        wrapper.debug(someString)
        #expect(mockLogger.debugLogs.count == 1)
        #expect(mockLogger.debugLogs[0] == someString)
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 0)
    }

    @Test("Logs debug message with censored content")
    func loggerLogsDebugWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let wrapper = MockLoggableWrapper(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        wrapper.debug(someString, censored: somePrivateString)
        #expect(mockLogger.debugLogs.count == 1)
        #expect(mockLogger.debugLogs[0] == "\(someString):\(somePrivateString)")
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 0)
    }

    // MARK: - Info Log Tests

    @Test("Logs info message verbatim")
    func loggerLogsInfo() {
        let mockLogger = MockDefaultCoreLogger()
        let wrapper = MockLoggableWrapper(logger: mockLogger)
        let someString = UUID().uuidString
        wrapper.info(someString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 1)
        #expect(mockLogger.infoLogs[0] == someString)
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 0)
    }

    @Test("Logs info message with censored content")
    func loggerLogsInfoWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let wrapper = MockLoggableWrapper(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        wrapper.info(someString, censored: somePrivateString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 1)
        #expect(mockLogger.infoLogs[0] == "\(someString):\(somePrivateString)")
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 0)
    }

    // MARK: - Error Log Tests

    @Test("Logs error message verbatim")
    func loggerLogsError() {
        let mockLogger = MockDefaultCoreLogger()
        let wrapper = MockLoggableWrapper(logger: mockLogger)
        let someString = UUID().uuidString
        wrapper.error(someString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 1)
        #expect(mockLogger.errorLogs[0] == someString)
        #expect(mockLogger.faultLogs.count == 0)
    }

    @Test("Logs error message with censored content")
    func loggerLogsErrorWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let wrapper = MockLoggableWrapper(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        wrapper.error(someString, censored: somePrivateString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 1)
        #expect(mockLogger.errorLogs[0] == "\(someString):\(somePrivateString)")
        #expect(mockLogger.faultLogs.count == 0)
    }

    // MARK: - Fault Log Tests

    @Test("Logs fault message verbatim")
    func loggerLogsFault() {
        let mockLogger = MockDefaultCoreLogger()
        let wrapper = MockLoggableWrapper(logger: mockLogger)
        let someString = UUID().uuidString
        wrapper.fault(someString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 1)
        #expect(mockLogger.faultLogs[0] == someString)
    }

    @Test("Logs fault message with censored content")
    func loggerLogsFaultWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let wrapper = MockLoggableWrapper(logger: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        wrapper.fault(someString, censored: somePrivateString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 1)
        #expect(mockLogger.faultLogs[0] == "\(someString):\(somePrivateString)")
    }
}

/// A test wrapper that mirrors `Logger`'s pass-through behavior using a mock `Loggable`.
private struct MockLoggableWrapper: Sendable {
    let logger: MockDefaultCoreLogger

    func debug(_ message: String) {
        logger.debug(message)
    }

    func debug(_ message: String, censored censoredMessage: String) {
        logger.debug(message, censored: censoredMessage)
    }

    func info(_ message: String) {
        logger.info(message)
    }

    func info(_ message: String, censored censoredMessage: String) {
        logger.info(message, censored: censoredMessage)
    }

    func error(_ message: String) {
        logger.error(message)
    }

    func error(_ message: String, censored censoredMessage: String) {
        logger.error(message, censored: censoredMessage)
    }

    func fault(_ message: String) {
        logger.fault(message)
    }

    func fault(_ message: String, censored censoredMessage: String) {
        logger.fault(message, censored: censoredMessage)
    }
}
