//
//  Volume.swift
//
//  Created by Kelvin Kosbab on 9/5/22.
//

import Foundation
import HealthKit

// MARK: - Volume

/// Deinfes a unit of volume.
@available(macOS 13.0, *)
public enum Volume : String, Unit {
    
    /// Liters is the SI unit of volume.
    case liters = "L"
    case usFluidOunces = "fl_oz_us"
    case ImperialFluidOunces = "fl_oz_imp"
    case usPint = "pt_us"
    case imperialPint = "pt_imp"
    case usCup = "cup_us"
    case imperialCup = "cup_imp"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .liters:
            return HKUnit.liter()
        case .usFluidOunces:
            return HKUnit.fluidOunceUS()
        case .ImperialFluidOunces:
            return HKUnit.fluidOunceImperial()
        case .usPint:
            return HKUnit.pintUS()
        case .imperialPint:
            return HKUnit.pintImperial()
        case .usCup:
            return HKUnit.cupUS()
        case .imperialCup:
            return HKUnit.cupImperial()
        }
    }
}
