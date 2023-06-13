//
//  HealthBiometricTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import XCTest
@testable import CoreHealth

// MARK: - HealthBiometricTests

@available(macOS 13.0, *)
class HealthBiometricTests : XCTestCase {
    
    /// Tests the expected raw values of `HealthBiometric.Type`. These values should not change.
    func testHealthBiometricTypeTests() {
        XCTAssert(CodableHealthBiometricType.quantity.rawValue == 0)
        XCTAssert(CodableHealthBiometricType.category.rawValue == 1)
        XCTAssert(CodableHealthBiometricType.correlation.rawValue == 2)
        XCTAssert(CodableHealthBiometricType.document.rawValue == 3)
        XCTAssert(CodableHealthBiometricType.workout.rawValue == 4)
    }
    
    /// Tests a single HealthKit quantity type biometirc to insure it correctly maps in the `HealthBiometric` type.
    func testHKQuantityTypeIdentifierBiometrics() {
        let bodyMassIndex = try? CodableHealthBiometric(identifier: .bodyMassIndex)
        XCTAssert(bodyMassIndex?.identifier == "HKQuantityTypeIdentifierBodyMassIndex")
        XCTAssert(bodyMassIndex?.biometricType == .quantity)
    }
    
    /// Tests a single HealthKit category type biometirc to insure it correctly maps in the `HealthBiometric` type.
    func testHKCategoryTypeIdentifierBiometrics() {
        let bodyMassIndex = try? CodableHealthBiometric(identifier: .sleepAnalysis)
        XCTAssert(bodyMassIndex?.identifier == "HKCategoryTypeIdentifierSleepAnalysis")
        XCTAssert(bodyMassIndex?.biometricType == .category)
    }
}
