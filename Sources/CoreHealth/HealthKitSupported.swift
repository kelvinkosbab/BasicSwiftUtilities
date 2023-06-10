//KitSupported.swift
//  
//
//  Created by Kelvin Kosbab on 7/10/22.
//

import Foundation
import HealthKit

// MARK: - HealthKitSupported

/// Defines objects that can determine if HealthKit is available on the specific platform.
@available(macOS 13.0, *)
public protocol HealthKitSupported {
    
    /// Accessing health data is not supported on all Apple devices.  Using `HKHealthStore` APIs on devices which are not
    /// supported will result in errors with the `HKErrorHealthDataUnavailable` code.  Call `isHealthDataAvailable`
    /// before attempting to use other parts of the framework.
    var isHealthDataAvailable: Bool { get }
}

// MARK: - HKHealthStore

@available(macOS 13.0, *)
extension HKHealthStore : HealthKitSupported {
    
    public var isHealthDataAvailable: Bool {
        return Self.isHealthDataAvailable()
    }
}
