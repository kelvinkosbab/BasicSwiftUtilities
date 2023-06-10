//
//  Count.swift
//
//  Created by Kelvin Kosbab on 9/17/22.
//

import Foundation
import HealthKit

// MARK: - Scalar

/// Deinfes a unit of time.
@available(macOS 13.0, *)
public enum Count : String, Unit {
    
    /// Seconds is the SI unit of time.
    case count = "count"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .count:
            return HKUnit.count()
        }
    }
}
