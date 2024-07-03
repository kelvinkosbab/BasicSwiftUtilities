//
//  Length.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import Foundation
import HealthKit

// MARK: - Length

/// Deinfes a unit of length.
@available(macOS 13.0, *)
public enum Length: String, Unit {

    // MARK: - Metric Units

    /// Meteres is the SI unit of length.
    case meters = "m"
    case centimeters = "cm"
    case millimeters = "mm"
    case kilometers = "km"

    // MARK: - Imperial Units

    case inches = "in"
    case feet = "ft"
    case yard = "yd"
    case miles = "mi"

    var healthKitUnit: HKUnit {
        switch self {
        case .meters:
            return HKUnit.meter()
        case .centimeters:
            return HKUnit.meterUnit(with: .centi)
        case .millimeters:
            return HKUnit.meterUnit(with: .milli)
        case .kilometers:
            return HKUnit.meterUnit(with: .kilo)

        case .inches:
            return HKUnit.inch()
        case .feet:
            return HKUnit.foot()
        case .yard:
            return HKUnit.yard()
        case .miles:
            return HKUnit.mile()
        }
    }
}

// MARK: - LengthBiometric

@available(macOS 13.0, watchOS 9.0, *)
public struct LengthBiometric: Biometric {

    public static let Units = Length.self

    public let healthKitIdentifier: HKQuantityTypeIdentifier

    /// A quantity sample type that measures the distance the user has moved by cycling.
    ///
    /// These samples use length units (described in `HKUnit`) and measure cumulative values (described in `HKStatisticsQuery`).
    public static let distanceCycling = Self(healthKitIdentifier: .distanceCycling)

    /// A quantity sample type that measures the distance the user has moved while swimming.
    ///
    /// These samples use length units (described in `HKUnit`) and measure cumulative values (described in `HKStatisticsQuery`).
    public static let distanceSwimming = Self(healthKitIdentifier: .distanceSwimming)

    /// A quantity sample type that measures the distance the user has moved by walking or running.
    ///
    /// These samples use length units (described in `HKUnit`) and measure cumulative values (described in `HKStatisticsQuery`).
    public static let distanceWalkingRunning = Self(healthKitIdentifier: .distanceWalkingRunning)

    /// A quantity sample type that measures the distance the user has moved using a wheelchair.
    ///
    /// These samples use length units (described in `HKUnit`) and measure cumulative values (described in `HKStatisticsQuery`).
    public static let distanceWheelchair = Self(healthKitIdentifier: .distanceWheelchair)

    /// A quantity sample type that measures the user’s height.
    ///
    /// These samples use length units (described in `HKUnit`) and measure discrete values (described in `HKStatisticsQuery`).
    public static let height = Self(healthKitIdentifier: .height)

    /// A quantity sample type that measures the distance covered by a single step while running.
    ///
    /// These samples use length units (described in `HKUnit`) and measure discrete values (described
    /// in `HKQuantityAggregationStyle`). During outdoor running workouts, the system automatically records
    /// running stride samples on Apple Watch SE and Series 6 and later.
    @available(iOS 16.0, *)
    public static let runningStrideLength = Self(healthKitIdentifier: .runningStrideLength)
}

// MARK: - QueryExecutor + Length

@available(iOS 13.0, macOS 13.0, watchOS 9.0, *)
public extension QueryExecutor {

    func fetch(
        _ biometric: LengthBiometric,
        in unit: LengthBiometric.UnitofMeasurement,
        options: QueryOptions
    ) async throws -> [Sample] {
        return try await self.query(
            identifier: biometric.healthKitIdentifier,
            unit: unit,
            options: options
        )
    }
}

// MARK: - BackgroundDelivery + LengthBiometric

@available(macOS 13.0, watchOS 9.0, *)
public extension BackgroundDeliveryEnabler {

    func enableBackgroundDelivery(
        for type: LengthBiometric,
        frequency: HKUpdateFrequency
    ) async throws {
        let biometric = try CodableHealthBiometric(identifier: type.healthKitIdentifier)
        try await self.enableBackgroundDelivery(for: biometric.sampleType, frequency: frequency)
    }

    func disableBackgroundDelivery(
        for type: LengthBiometric
    ) async throws {
        let biometric = try CodableHealthBiometric(identifier: type.healthKitIdentifier)
        try await self.disableBackgroundDelivery(for: biometric.sampleType)
    }
}

#endif
