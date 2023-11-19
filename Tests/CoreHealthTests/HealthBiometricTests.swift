//
//  HealthBiometricTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import XCTest
@testable import CoreHealth

// MARK: - HealthBiometricTests

@available(macOS 13.0, *)
class HealthBiometricTests : XCTestCase {
    
    /// Tests the expected raw values of `HealthBiometric.Type`. These values should not change.
    func testHealthBiometricTypeTests() {
        XCTAssertEqual(
            CodableHealthBiometricType.quantity.rawValue,
            0
        )
        XCTAssertEqual(
            CodableHealthBiometricType.category.rawValue,
            1
        )
        XCTAssertEqual(
            CodableHealthBiometricType.correlation.rawValue,
            2
        )
        XCTAssertEqual(
            CodableHealthBiometricType.document.rawValue,
            3
        )
        XCTAssertEqual(
            CodableHealthBiometricType.workout.rawValue,
            4
        )
    }
    
    /// Tests a single HealthKit quantity type biometirc to insure it correctly maps in the `HealthBiometric` type.
    func testHKQuantityTypeIdentifierBiometrics() {
        let bodyMassIndex = try? CodableHealthBiometric(identifier: .bodyMassIndex)
        XCTAssertEqual(
            bodyMassIndex?.identifier,
            "HKQuantityTypeIdentifierBodyMassIndex"
        )
        XCTAssertEqual(
            bodyMassIndex?.biometricType,
            .quantity
        )
    }
    
    /// Tests a single HealthKit category type biometirc to insure it correctly maps in the `HealthBiometric` type.
    func testHKCategoryTypeIdentifierBiometrics() {
        let bodyMassIndex = try? CodableHealthBiometric(identifier: .sleepAnalysis)
        XCTAssertEqual(
            bodyMassIndex?.identifier,
            "HKCategoryTypeIdentifierSleepAnalysis"
        )
        XCTAssertEqual(
            bodyMassIndex?.biometricType,
            .category
        )
    }
}

#endif
