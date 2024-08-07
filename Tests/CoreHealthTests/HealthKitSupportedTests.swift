//
//  HealthKitSupportedTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import XCTest
import HealthKit
@testable import CoreHealth

#if !os(macOS)
import UIKit
#endif

// MARK: - HealthKitSupportedTests

class HealthKitSupportedTests: XCTestCase {

    /// HealthKit's static `isHealthDataAvailable()` method is meant to help developers determine if the platform supports
    /// querying health data. However, ther is not much information as to what platforms it supports and if that platform support
    /// changes. This test is meant to dtermine the current state of platform support for HealthKit as well as to track any future
    /// changes to platform support on Apple platforms.
    @available(macOS 13.0, *)
    func testExpectedHealthKitPlatformSupport() {
        #if os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            XCTAssertEqual(
                HKHealthStore().isHealthDataAvailable,
                true
            )
        case .pad:
            if #available(iOS 17.0, *) {
                XCTAssertEqual(
                    HKHealthStore().isHealthDataAvailable,
                    true
                )
            } else {
                XCTAssertEqual(
                    HKHealthStore().isHealthDataAvailable,
                    false
                )
            }
        default:
            XCTFail("Platform unsupported by test case")
        }
        #elseif os(watchOS)
        XCTAssertEqual(
            HKHealthStore().isHealthDataAvailable,
            true
        )
        #elseif os(tvOS)
        XCTAssertEqual(
            HKHealthStore().isHealthDataAvailable,
            false
        )
        #elseif os(macOS)
        XCTAssertEqual(
            HKHealthStore().isHealthDataAvailable,
            false
        )
        #endif
    }
}

#endif
