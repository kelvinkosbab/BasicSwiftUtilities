//
//  Pressure.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import Foundation
import HealthKit

// MARK: - Pressure

/// Deinfes a unit of pressure.
@available(iOS 14.0, macOS 13.0, watchOS 7.0, *)
public enum Pressure: String, Unit {

    /// Pascals is the SI unit of pressure.
    case pascals = "Pa"
    case mmHg = "mmHg"
    case cmAq = "cmAq"
    case atm = "atm"
    case dBASPL = "dBASPL"
    case inHg = "inHg"

    var healthKitUnit: HKUnit {
        switch self {
        case .pascals:
            return HKUnit.pascal()
        case .mmHg:
            return HKUnit.millimeterOfMercury()
        case .cmAq:
            return HKUnit.centimeterOfWater()
        case .atm:
            return HKUnit.atmosphere()
        case .dBASPL:
            return HKUnit.decibelAWeightedSoundPressureLevel()
        case .inHg:
            return HKUnit.inchesOfMercury()
        }
    }
}

#endif
