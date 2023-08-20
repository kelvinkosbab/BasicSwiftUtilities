//
//  RunMode.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Protocols

/// Protocol for objects that determine whether or not a unit test or UI unit test is currently running.
protocol UnitTestStatusProvider {
    
    /// Returns whether or not a unit test is currently running (excludes UI unit tests).
    var isUnitTest: Bool { get }
    
    /// Returns whether or not a UI unit test is currently running.
    var isUIUnitTest: Bool { get }
}

// MARK: - UnitTestStatus

struct UnitTestStatus : UnitTestStatusProvider {
    
    var isUnitTest: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    var isUIUnitTest: Bool {
        return CommandLine.arguments.contains("--uitesting")
    }
}

// MARK: - RunMode

/// Determines the active run mode off the application.
///
/// Options include:
/// - Main application
/// - Unit tests
/// - UI unit tests
///
/// To determine the current process's ``RunMode``:
/// ```swift
/// let activeRunMode = RunMode.getActive()
/// ```
public enum RunMode {
    
    /// The process is running the main application.
    case mainApplication
    
    /// The process is running unit tests.
    case unitTests
    
    /// The process is running UI unit tests.
    case uiUnitTests
    
    // MARK: - Current Run Mode
    
    /// Returns the active ``RunMode`` of the application.
    public static func getActive() -> RunMode {
        return self.getActive(unitTestStatusProvider: UnitTestStatus())
    }
    
    /// Returns the active ``RunMode`` of the application.
    ///
    /// Note: Marked `internal` for unit testing.
    ///
    /// - Parameter unitTestStatusProvider: Provides the status of unit tests that may or may not be running.
    internal static func getActive(
        unitTestStatusProvider: UnitTestStatusProvider
    ) -> RunMode {
        
        // Checks if unit tests are running (excludes UI unit tests)
        if unitTestStatusProvider.isUnitTest {
            return .unitTests
        }
        
        // Checks if UI unit tests are running
        if unitTestStatusProvider.isUIUnitTest {
            return .uiUnitTests
        }
        
        // No tests ar running. The main application is running.
        return .mainApplication
    }
}
