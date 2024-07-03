//
//  Angle.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import Foundation
import HealthKit

// MARK: - Angle

/// Deinfes a unit of rotation.
@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public enum Angle: String, Unit {

    /// Radians is the SI unit of angle measurements.
    case radians = "rad"
    case degrees = "degree"

    var healthKitUnit: HKUnit {
        switch self {
        case .radians:
            return HKUnit.radianAngle()
        case .degrees:
            return HKUnit.degreeAngle()
        }
    }
}

#endif
