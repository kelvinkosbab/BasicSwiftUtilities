//
//  CardioFitness.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import Foundation
import HealthKit

// MARK: - CardioFitness

/// VO2 max (also maximal oxygen consumption, maximal oxygen uptake or maximal aerobic capacity) is the maximum rate of oxygen
/// consumption measured during incremental exercise; that is, exercise of increasing intensity.[1][2] The name is derived from three
/// abbreviations: "V̇" for volume (the dot appears over the V to indicate "per unit of time"), "O2" for oxygen, and "max" for maximum.
///
/// The measurement of V̇O2 max in the laboratory provides a quantitative value of endurance fitness for comparison of individual
/// training effects and between people in endurance training. Maximal oxygen consumption reflects cardiorespiratory fitness and
/// endurance capacity in exercise performance. Elite athletes, such as competitive distance runners, racing cyclists or Olympic
/// cross-country skiers, can achieve V̇O2 max values exceeding 90 mL/(kg·min), while some endurance animals, such as Alaskan
/// huskies, have V̇O2 max values exceeding 200 mL/(kg·min).
@available(macOS 13.0, *)
public enum CardioFitness : String, Unit {
    
    /// Standard unit for `vo2max` (`mL/kg·min`).
    case mLkgPerMin = "mL/min·kg"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .mLkgPerMin:
            return HKUnit
                .literUnit(with: .milli)
                .unitMultiplied(by: HKUnit.gramUnit(with: .kilo))
                .unitDivided(by: HKUnit.minute())
        }
    }
}

// MARK: - CardioFitnessBiometric

@available(macOS 13.0, *)
public struct CardioFitnessBiometric : Biometric {
    
    public static let Units = CardioFitness.self
    
    public let healthKitIdentifier: HKQuantityTypeIdentifier
    
    /// A quantity sample that measures the maximal oxygen consumption during exercise.
    ///
    /// VO2max—the maximum amount of oxygen your body can consume during exercise— is a strong predictor of overall
    /// health. Clinical tests measure VO2max by having the patient exercise on a treadmill or bike, with an intensity that
    /// increases every few minutes until exhaustion.
    ///
    /// On Apple Watch Series 3 or later, the system automatically saves `vo2Max` samples to HealthKit. The watch estimates
    /// the user’s VO2max based on data gathered while the user is walking or running outdoors. For more information,
    /// see [Understand Estimated Test Results](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/3552083-sixminutewalktestdistance#3683764).
    ///
    /// You can also create and save your own `vo2Max` samples—for example, when creating an app that records the
    /// results of tests performed in a clinic. When creating vo2Max samples, use the `HKMetadataKeyVO2MaxTestType`
    /// metadata key to specify the type of test used to generate the sample.
    ///
    /// `vo2Max` samples use volume/mass/time units (described in `HKUnit`), measured in ml/kg /min. They measure
    /// discrete values (described in `HKStatisticsQuery`).
    ///
    /// For more info see [Apple's vo2max documentation](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/2867757-vo2max).
    public static let vo2Max = Self(healthKitIdentifier: .vo2Max)
}

// MARK: - QueryExecutor + CardioFitness

@available(iOS 13.0, macOS 13.0, watchOS 8.0, *)
public extension QueryExecutor {
    
    func fetch(
        _ biometric: CardioFitnessBiometric,
        in unit: CardioFitnessBiometric.UnitofMeasurement,
        options: QueryOptions
    ) async throws -> [Sample] {
        return try await self.query(
            identifier: biometric.healthKitIdentifier,
            unit: unit,
            options: options
        )
    }
}


// MARK: - BackgroundDelivery + CardioFitness

@available(macOS 13.0, *)
public extension BackgroundDeliveryEnabler {
    
    func enableBackgroundDelivery(
        for type: CardioFitnessBiometric,
        frequency: HKUpdateFrequency
    ) async throws {
        let biometric = try CodableHealthBiometric(identifier: type.healthKitIdentifier)
        try await self.enableBackgroundDelivery(for: biometric.sampleType, frequency: frequency)
    }
    
    func disableBackgroundDelivery(
        for type: CardioFitnessBiometric
    ) async throws {
        let biometric = try CodableHealthBiometric(identifier: type.healthKitIdentifier)
        try await self.disableBackgroundDelivery(for: biometric.sampleType)
    }
}

#endif
