//
//  Time.swift
//
//  Created by Kelvin Kosbab on 9/5/22.
//

import Foundation
import HealthKit

// MARK: - Time

/// Deinfes a unit of time.
@available(macOS 13.0, *)
public enum Time : String, Unit {
    
    /// Seconds is the SI unit of time.
    case seconds = "s"
    case minutes = "min"
    case hours = "hr"
    case days = "d"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .seconds:
            return HKUnit.second()
        case .minutes:
            return HKUnit.minute()
        case .hours:
            return HKUnit.hour()
        case .days:
            return HKUnit.day()
        }
    }
}

// MARK: - TimeBiometric

/// Defines a time biometric.
@available(iOS 13.0, macOS 13.0, watchOS 6.0, *)
public struct TimeBiometric : Biometric {
    
    public static let Units = Time.self
    
    public let healthKitIdentifier: HKQuantityTypeIdentifier
    
    /// A quantity sample type that measures the amount of time the user spent exercising.
    ///
    /// This quantity type measures every full minute of movement that equals or exceeds the intensity of a brisk walk.
    ///
    /// Apple watch automatically records exercise time. By default, the watch uses the accelerometer to estimate the
    /// intensity of the user’s movement. However, during workout sessions, the watch uses additional sensors, like the
    /// heart rate sensor and GPS, to generate estimates.
    ///
    /// `HKWorkoutSession` sessions also contribute to the exercise time. For more information, see Fill the Activity
    /// Rings.
    ///
    /// These samples use time units (described in `HKUnit`) and measure cumulative values (described in `HKStatisticsQuery`).
    public static let appleExerciseTime = Self(healthKitIdentifier: .appleExerciseTime)
    
    /// A quantity sample type that measures the amount of time the user has spent standing.
    ///
    /// These samples use time units (described in `HKUnit`) and measure cumulative values (described in `HKStatisticsQuery`).
    public static let appleStandTime = Self(healthKitIdentifier: .appleStandTime)
}

// MARK: - QueryExecutor + Time

@available(iOS 13.0, macOS 13.0, watchOS 8.0, *)
public extension QueryExecutor {
    
    func fetch(
        _ biometric: TimeBiometric,
        in unit: TimeBiometric.UnitofMeasurement,
        options: QueryOptions
    ) async throws -> [Sample] {
        return try await self.query(
            identifier: biometric.healthKitIdentifier,
            unit: unit,
            options: options
        )
    }
}

// MARK: - BackgroundDelivery + TemperatureBiometric

@available(iOS 13.0, macOS 13.0, watchOS 6.0, *)
public extension BackgroundDeliveryEnabler {
    
    func enableBackgroundDelivery(
        for type: TimeBiometric,
        frequency: HKUpdateFrequency
    ) async throws {
        let biometric = try CodableHealthBiometric(identifier: type.healthKitIdentifier)
        try await self.enableBackgroundDelivery(for: biometric.sampleType, frequency: frequency)
    }
    
    func disableBackgroundDelivery(
        for type: TimeBiometric
    ) async throws {
        let biometric = try CodableHealthBiometric(identifier: type.healthKitIdentifier)
        try await self.disableBackgroundDelivery(for: biometric.sampleType)
    }
}
