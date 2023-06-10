//
//  Percent.swift
//
//  Created by Kelvin Kosbab on 9/17/22.
//

import Foundation
import HealthKit

/// Deinfes a unit of time.
@available(macOS 13.0, *)
public enum Percent : String, Unit {
    
    /// Seconds is the SI unit of time.
    case percent = "%"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .percent:
            return HKUnit.percent()
        }
    }
}
