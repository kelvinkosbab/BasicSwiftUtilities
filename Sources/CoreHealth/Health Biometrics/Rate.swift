//
//  Rate.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import HealthKit

// MARK: - Rate

/// Defines a unit of rate.
@available(macOS 13.0, *)
public enum Rate : String, Unit {
    
    case countPerSecond = "count/second"
    case countPerMinute = "count/minute"
    case countPerHour = "count/hour"
    case countPerDay = "count/day"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .countPerSecond:
            return HKUnit.count().unitDivided(by: HKUnit.second())
        case .countPerMinute:
            return HKUnit.count().unitDivided(by: HKUnit.minute())
        case .countPerHour:
            return HKUnit.count().unitDivided(by: HKUnit.hour())
        case .countPerDay:
            return HKUnit.count().unitDivided(by: HKUnit.day())
        }
    }
}

// MARK: - RateBiometric

@available(macOS 13.0, *)
public struct RateBiometric : Biometric {
    
    public static let Units = Rate.self
    
    public let healthKitIdentifier: HKQuantityTypeIdentifier
    
    /// A quantity sample type that measures the user’s heart rate.
    ///
    /// These samples use count/time units (described in HKUnit) and measure discrete values (described in `HKStatisticsQuery`).
    ///
    /// Heart rate samples may include motion context information, which is stored as metadata using the
    /// `HKMetadataKeyHeartRateMotionContext` key. The value of this key is an NSNumber object that contains a
    /// `HKHeartRateMotionContext` value.
    ///
    /// The motion context gives additional information about the user’s activity level when the heart rate sample was taken.
    /// Apple Watch uses the following guidelines when setting the motion context:
    ///
    /// 1. If the user has been still for at least 5 minutes prior to the sample, the context is set to the
    /// `HKHeartRateMotionContext.sedentary` value.
    /// 2.  If the user is in motion, the context is set to the `HKHeartRateMotionContext`.active value.
    ///
    /// You can add motion context to the metadata of any heart rate samples that you create. This means other apps may
    /// also save heart rate samples with (or without) the `HKMetadataKeyHeartRateMotionContext` metadata key.
    ///
    /// Note that not all heart rate samples have a motion context. For example, if Apple Watch cannot determine the
    /// motion context, it creates samples without a HKMetadataKeyHeartRateMotionContext metadata key. In addition,
    /// heart rate samples recorded by an Apple Watch (1st generation) or by a device running watchOS 3 or earlier do not
    /// have the motion context metadata key. Treat these samples as if they used the
    /// `HKHeartRateMotionContext.notSet` motion context.
    public static let heartRate = Self(healthKitIdentifier: .heartRate)
    
    /// A quantity sample type that measures the user’s respiratory rate.
    ///
    /// These samples use count/time units (described in `HKUnit`) and measure discrete values (described in `HKStatisticsQuery`).
    public static let respiratoryRate = Self(healthKitIdentifier: .respiratoryRate)
}

// MARK: - QueryExecutor + Rate

@available(iOS 13.0, macOS 13.0, watchOS 8.0, *)
public extension QueryExecutor {
    
    func fetch(
        _ biometric: RateBiometric,
        in unit: RateBiometric.UnitofMeasurement,
        options: QueryOptions
    ) async throws -> [Sample] {
        return try await self.query(
            identifier: biometric.healthKitIdentifier,
            unit: unit,
            options: options
        )
    }
}

// MARK: - BackgroundDelivery + RateBiometric

@available(macOS 13.0, *)
public extension BackgroundDeliveryEnabler {
    
    func enableBackgroundDelivery(
        for type: RateBiometric,
        frequency: HKUpdateFrequency
    ) async throws {
        let biometric = try CodableHealthBiometric(identifier: type.healthKitIdentifier)
        try await self.enableBackgroundDelivery(for: biometric.sampleType, frequency: frequency)
    }
    
    func disableBackgroundDelivery(
        for type: RateBiometric
    ) async throws {
        let biometric = try CodableHealthBiometric(identifier: type.healthKitIdentifier)
        try await self.disableBackgroundDelivery(for: biometric.sampleType)
    }
}
