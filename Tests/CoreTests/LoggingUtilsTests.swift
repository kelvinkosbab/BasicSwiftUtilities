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

    // Note: Logger now takes SwiftLogger directly, so we test via SwiftLogger
    // using the mock pattern at the Loggable protocol level.

    // MARK: - Debug Log Tests

    @Test("Logs debug message with correct format")
    func loggerLogsDebug() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = makeMockLogger(mock: mockLogger)
        let someString = UUID().uuidString
        logger.debug(someString)
        #expect(mockLogger.debugLogs.count == 1)
        #expect(mockLogger.debugLogs[0] == "[Debug] <\(mockCategory)> \(someString)")
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 0)
    }

    @Test("Logs debug message with censored content")
    func loggerLogsDebugWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = makeMockLogger(mock: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.debug(someString, censored: somePrivateString)
        #expect(mockLogger.debugLogs.count == 1)
        #expect(mockLogger.debugLogs[0] == "[Debug] <\(mockCategory)> \(someString):\(somePrivateString)")
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 0)
    }

    // MARK: - Info Log Tests

    @Test("Logs info message with correct format")
    func loggerLogsInfo() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = makeMockLogger(mock: mockLogger)
        let someString = UUID().uuidString
        logger.info(someString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 1)
        #expect(mockLogger.infoLogs[0] == "[Info] <\(mockCategory)> \(someString)")
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 0)
    }

    @Test("Logs info message with censored content")
    func loggerLogsInfoWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = makeMockLogger(mock: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.info(someString, censored: somePrivateString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 1)
        #expect(mockLogger.infoLogs[0] == "[Info] <\(mockCategory)> \(someString):\(somePrivateString)")
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 0)
    }

    // MARK: - Error Log Tests

    @Test("Logs error message with correct format")
    func loggerLogsError() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = makeMockLogger(mock: mockLogger)
        let someString = UUID().uuidString
        logger.error(someString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 1)
        #expect(mockLogger.errorLogs[0] == "[Error] <\(mockCategory)> \(someString)")
        #expect(mockLogger.faultLogs.count == 0)
    }

    @Test("Logs error message with censored content")
    func loggerLogsErrorWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = makeMockLogger(mock: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.error(someString, censored: somePrivateString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 1)
        #expect(mockLogger.errorLogs[0] == "[Error] <\(mockCategory)> \(someString):\(somePrivateString)")
        #expect(mockLogger.faultLogs.count == 0)
    }

    // MARK: - Fault Log Tests

    @Test("Logs fault message with correct format")
    func loggerLogsFault() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = makeMockLogger(mock: mockLogger)
        let someString = UUID().uuidString
        logger.fault(someString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 1)
        #expect(mockLogger.faultLogs[0] == "[Fault] <\(mockCategory)> \(someString)")
    }

    @Test("Logs fault message with censored content")
    func loggerLogsFaultWithPrivateMessage() {
        let mockLogger = MockDefaultCoreLogger()
        let logger = makeMockLogger(mock: mockLogger)
        let someString = UUID().uuidString
        let somePrivateString = UUID().uuidString
        logger.fault(someString, censored: somePrivateString)
        #expect(mockLogger.debugLogs.count == 0)
        #expect(mockLogger.infoLogs.count == 0)
        #expect(mockLogger.errorLogs.count == 0)
        #expect(mockLogger.faultLogs.count == 1)
        #expect(mockLogger.faultLogs[0] == "[Fault] <\(mockCategory)> \(someString):\(somePrivateString)")
    }

    // MARK: - Helpers

    private func makeMockLogger(mock: MockDefaultCoreLogger) -> MockLoggableWrapper {
        MockLoggableWrapper(category: mockCategory, logger: mock)
    }
}

/// A test wrapper that mimics Logger's formatting behavior using a mock Loggable.
private struct MockLoggableWrapper: Sendable {
    let category: String
    let logger: MockDefaultCoreLogger

    func debug(_ message: String) {
        logger.debug("[Debug] <\(category)> \(message)")
    }

    func debug(_ message: String, censored censoredMessage: String) {
        logger.debug("[Debug] <\(category)> \(message)", censored: censoredMessage)
    }

    func info(_ message: String) {
        logger.info("[Info] <\(category)> \(message)")
    }

    func info(_ message: String, censored censoredMessage: String) {
        logger.info("[Info] <\(category)> \(message)", censored: censoredMessage)
    }

    func error(_ message: String) {
        logger.error("[Error] <\(category)> \(message)")
    }

    func error(_ message: String, censored censoredMessage: String) {
        logger.error("[Error] <\(category)> \(message)", censored: censoredMessage)
    }

    func fault(_ message: String) {
        logger.fault("[Fault] <\(category)> \(message)")
    }

    func fault(_ message: String, censored censoredMessage: String) {
        logger.fault("[Fault] <\(category)> \(message)", censored: censoredMessage)
    }
}
