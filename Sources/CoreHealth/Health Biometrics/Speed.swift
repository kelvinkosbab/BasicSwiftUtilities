//
//  Speed.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import HealthKit

// MARK: - Speed

/// Deinfes a unit of speed.
@available(macOS 13.0, *)
public enum Speed : String, Unit {
    
    case metersPerSecond = "m/s"
    case kilometersPerHour = "km/h"
    case milesPerHour = "m/h"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .metersPerSecond:
            return HKUnit.meter().unitDivided(by: HKUnit.second())
        case .kilometersPerHour:
            return HKUnit.meterUnit(with: .kilo).unitDivided(by: HKUnit.hour())
        case .milesPerHour:
            return HKUnit.mile().unitDivided(by: HKUnit.hour())
        }
    }
}
