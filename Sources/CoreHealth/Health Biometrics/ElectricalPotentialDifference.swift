//
//  ElectricalPotentialDifference.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import Foundation
import HealthKit

// MARK: - Electric Potential Difference

/// Deinfes a unit of electric potential difference.
@available(iOS 14.0, macOS 13.0, watchOS 7.0, *)
public enum ElectricalPotentialDifference: String, Unit {

    // Volts is the SI unit of electric potential.
    case volts = "V"

    var healthKitUnit: HKUnit {
        switch self {
        case .volts:
            return HKUnit.volt()
        }
    }
}

#endif
