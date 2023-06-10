//
//  Frequency.swift
//
//  Created by Kelvin Kosbab on 9/5/22.
//

import Foundation
import HealthKit

// MARK: - Frequency

/// Deinfes a unit of electrical frequency.
@available(iOS 13.0, macOS 13.0, watchOS 6.0, *)
public enum Frequency : String, Unit {
    
    // Hertz is the SI unit of electrical frequency.
    case hertz = "Hz"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .hertz:
            return HKUnit.hertz()
        }
    }
}
