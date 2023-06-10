//
//  Mass.swift
//
//  Created by Kelvin Kosbab on 9/5/22.
//

import Foundation
import HealthKit

// MARK: - Mass

/// Defines a unit of mass.
@available(macOS 13.0, *)
public enum Mass : String, Unit {
    
    /// Grams is the SI unit of mass.
    case grams = "g"
    case ounces = "oz"
    case pounds = "lb"
    case stones = "st"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .grams:
            return HKUnit.gram()
        case .ounces:
            return HKUnit.ounce()
        case .pounds:
            return HKUnit.pound()
        case .stones:
            return HKUnit.stone()
        }
    }
}
