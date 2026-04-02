//
//  RunModeTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
@testable import RunMode

// MARK: - Mocks

struct MockUnitTestStatusProvider: UnitTestStatusProvider {
    let isUnitTest: Bool
    let isUIUnitTest: Bool
}

// MARK: - RunModeTests

@Suite("RunMode")
struct RunModeTests {

    @Test("Returns mainApplication when not in tests")
    func returnMainApplication() {
        let provider = MockUnitTestStatusProvider(
            isUnitTest: false,
            isUIUnitTest: false
        )
        let result = RunMode.getActive(unitTestStatusProvider: provider)
        #expect(result == .mainApplication)
    }

    @Test("Returns unitTests when running unit tests")
    func returnUnitTests() {
        let provider = MockUnitTestStatusProvider(
            isUnitTest: true,
            isUIUnitTest: false
        )
        let result = RunMode.getActive(unitTestStatusProvider: provider)
        #expect(result == .unitTests)
    }

    @Test("Returns uiUnitTests when running UI tests")
    func returnUIUnitTests() {
        let provider = MockUnitTestStatusProvider(
            isUnitTest: false,
            isUIUnitTest: true
        )
        let result = RunMode.getActive(unitTestStatusProvider: provider)
        #expect(result == .uiUnitTests)
    }
}
