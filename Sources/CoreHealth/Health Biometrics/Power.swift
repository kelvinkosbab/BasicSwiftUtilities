//
//  Power.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import Foundation
import HealthKit

// MARK: - Power

/// Deinfes a unit of power.
@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public enum Power : String, Unit {
    
    // Watts is the SI unit of power.
    case watts = "W"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .watts:
            return HKUnit.watt()
        }
    }
}

#endif
