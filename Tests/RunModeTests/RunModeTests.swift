//
//  RunModeTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import XCTest
@testable import RunMode

// MARK: - Mocks

struct MockUnitTestStatusProvider : UnitTestStatusProvider {
    let isUnitTest: Bool
    let isUIUnitTest: Bool
}

// MARK: - RunModeTests

final class RunModeTests: XCTestCase {
    
    /// Should return `RunMode.mainApplication` if not running unit tests
    func testReturnMainApplication() {
        let provider = MockUnitTestStatusProvider(
            isUnitTest: false,
            isUIUnitTest: false
        )
        let result = RunMode.getActive(unitTestStatusProvider: provider)
        XCTAssertEqual(
            result,
            .mainApplication
        )
    }
    
    /// Should return `RunMode.unitTests` if not running unit tests
    func testReturnUnitTests() {
        let provider = MockUnitTestStatusProvider(
            isUnitTest: true,
            isUIUnitTest: false
        )
        let result = RunMode.getActive(unitTestStatusProvider: provider)
        XCTAssertEqual(
            result,
            .unitTests
        )
    }
    
    /// Should return `RunMode.uiUnitTests` if not running unit tests
    func testReturnUIUnitTests() {
        let provider = MockUnitTestStatusProvider(
            isUnitTest: false,
            isUIUnitTest: true
        )
        let result = RunMode.getActive(unitTestStatusProvider: provider)
        XCTAssertEqual(
            result,
            .uiUnitTests
        )
    }
}
