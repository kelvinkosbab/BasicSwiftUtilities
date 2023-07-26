//
//  BackgroundDelivery.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import Foundation
import HealthKit
import Core

// MARK: - BackgroundDeliveryEnabler

@available(macOS 13.0, *)
public protocol BackgroundDeliveryEnabler {
    
    /// Enable the delivery of updates to an app running in the background.
    ///
    /// For more info see [Apple's documentation](https://developer.apple.com/documentation/healthkit/hkhealthstore/1614175-enablebackgrounddelivery).
    ///
    /// **Important**
    ///
    /// For iOS 15 and watchOS 8, you must enable the HealthKit Background Delivery by adding the com.apple
    /// developer.healthkit.background-delivery entitlement to your app. If your app doesn’t have this entitlement, the
    /// `enableBackgroundDelivery(for:frequency:withCompletion:)` method fails with
    /// an` HKError.Code.errorAuthorizationDenied` error.
    ///
    /// - Parameter type: The type of data to observe. This object can be any concrete subclass of the `HKObjectType`
    /// class (such as `HKCharacteristicType` , `HKQuantityType`, `HKCategoryType`, `HKWorkoutType`,
    /// or `HKCorrelationType`).
    /// - Parameter frequency: The maximum frequency of the updates. The system wakes your app from the
    /// background at most once per time period specified. For a complete list of valid frequencies, see
    /// [HKUpdateFrequency](https://developer.apple.com/documentation/healthkit/hkupdatefrequency).
    ///
    /// - Throws if there was an error enabling background delivery.
    func enableBackgroundDelivery(
        for type: HKObjectType,
        frequency: HKUpdateFrequency
    ) async throws
    
    /// Disables background deliveries of update notifications for the specified data type.
    ///
    /// For more info see [Apple's documentation](https://developer.apple.com/documentation/healthkit/hkhealthstore/1614177-disablebackgrounddelivery).
    ///
    /// - Parameter type: The type of data to observe. This object can be any concrete subclass of the `HKObjectType`
    /// class (such as `HKCharacteristicType` , `HKQuantityType`, `HKCategoryType`, `HKWorkoutType`,
    /// or `HKCorrelationType`).
    ///
    /// - Throws if there was an error disabling background delivery.
    func disableBackgroundDelivery(
        for type: HKObjectType
    ) async throws
    
    /// Disables all background deliveries of update notifications.
    ///
    /// For more info see [Apple's documentation](https://developer.apple.com/documentation/healthkit/hkhealthstore/1614158-disableallbackgrounddelivery).
    ///
    /// - Throws if there was an error disabling background delivery.
    func disableAllBackgroundDelivery() async throws
}

// MARK: - BackgroundDeliveryError

/// Defines errors thrown by HealthKit enable background delivery.
public enum BackgroundDeliveryError : Error {
    
    /// Thrown when `enableBackgroundDelivery` fails for unknown reasons.
    case unknownError
}

// MARK: - HKHealthStore & BackgroundDelivery

@available(iOS 13.0, macOS 13.0, watchOS 8.0, *)
extension HKHealthStore : BackgroundDeliveryEnabler {
    
    public func enableBackgroundDelivery(
        for type: HKObjectType,
        frequency: HKUpdateFrequency
    ) async throws {
        try await withCheckedThrowingVoidContinuation { continuation in
            self.enableBackgroundDelivery(
                for: type,
                frequency: frequency
            ) { success, error in
                
                if success {
                    continuation.resume()
                    return
                }
                
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: BackgroundDeliveryError.unknownError)
                }
            }
        }
    }
    
    public func disableBackgroundDelivery(
        for type: HKObjectType
    ) async throws {
        try await withCheckedThrowingVoidContinuation { continuation in
            self.disableBackgroundDelivery(for: type) { success, error in
                
                if success {
                    continuation.resume()
                    return
                }
                
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: BackgroundDeliveryError.unknownError)
                }
            }
        }
    }

    /// Disables all background deliveries of update notifications.
    ///
    /// For more info see [Apple's documentation](https://developer.apple.com/documentation/healthkit/hkhealthstore/1614158-disableallbackgrounddelivery).
    ///
    /// - Throws if there was an error disabling background delivery.
    public func disableAllBackgroundDelivery() async throws {
        try await withCheckedThrowingVoidContinuation { continuation in
            self.disableAllBackgroundDelivery() { success, error in
                
                if success {
                    continuation.resume()
                    return
                }
                
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: BackgroundDeliveryError.unknownError)
                }
            }
        }
    }
}

#endif
