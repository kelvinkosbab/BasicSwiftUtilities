//
//  ElectricalConductance.swift
//
//  Created by Kelvin Kosbab on 9/5/22.
//

import Foundation
import HealthKit

// MARK: - Electrical Conductance

/// Deinfes a unit of electrical conductance.
@available(macOS 13.0, *)
public enum ElectricalConductance : String, Unit {
    
    /// Siemens is the SI unit of electical conductance.
    case siemens = "S"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .siemens:
            return HKUnit.siemen()
        }
    }
}
