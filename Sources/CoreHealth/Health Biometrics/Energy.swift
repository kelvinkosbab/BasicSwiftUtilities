//
//  Energy.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import HealthKit

// MARK: - Energy

/// Deinfes a unit of energy.
@available(macOS 13.0, *)
public enum Energy : String, Unit {
    
    /// Joules is the SI unit of energy/
    case joules = "joules"
    
    /// The kilocalorie is used to measure food energy in many regions.
    case kcal = "kcal"
    
    /// The large calorie is the same as a kilocalorie (1 Cal = 4184.0 J).
    case largeCal = "largeCalorie"
    
    /// This unit represents the gram calorie, or the amount of energy needed to raise 1 gram of
    /// water by 1 degree Celsius (1 cal = 4.1840 J).
    ///
    /// This unit is occasionally used in chemistry and other sciences, but it should not be confused with the kilocalorie,
    /// or large calorie, which is used for measuring food energy in many regions.
    case smallCal = "smallCalorie"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .joules:
            return HKUnit.joule()
        case .kcal:
            return HKUnit.kilocalorie()
        case .largeCal:
            return HKUnit.largeCalorie()
        case .smallCal:
            return HKUnit.smallCalorie()
        }
    }
}

// MARK: - EnergyBiometric

/// Defines an energy biometric.
@available(macOS 13.0, *)
public struct EnergyBiometric : Biometric {
    
    public static let Units = Energy.self
    
    public let healthKitIdentifier: HKQuantityTypeIdentifier
    
    /// A quantity sample type that measures the resting energy burned by the user.
    ///
    /// Resting energy is the energy that the user’s body burns to maintain its normal, resting state. The body uses this energy to
    /// perform basic functions like breathing, circulating blood, and managing the growth and maintenance of cells. These
    /// samples use energy units (described in `HKUnit`) and measure cumulative values (described in `HKStatisticsQuery`).
    public static let basalEnergyBurned = Self(healthKitIdentifier: .basalEnergyBurned)
    
    /// A quantity sample type that measures the amount of active energy the user has burned.
    ///
    /// Active energy is the energy that the user has burned due to physical activity and exercise. These samples should not
    /// include the resting energy burned during the sample’s duration. Use the health store’s
    /// `splitTotalEnergy(_:start:end:resultsHandler:)` method to split a workout’s total energy burned into
    /// the active and resting portions, and then save each portion in its own sample.
    ///
    /// Active energy samples use energy units (described in HKUnit) and measure cumulative values (described in HKStatisticsQuery).
    public static let activeEnergyBurned = Self(healthKitIdentifier: .activeEnergyBurned)
}
