//
//  Count.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import Foundation
import HealthKit

// MARK: - Scalar

/// Deinfes a unit of time.
@available(macOS 13.0, *)
public enum Count : String, Unit {
    
    /// Seconds is the SI unit of time.
    case count = "count"
    
    var healthKitUnit: HKUnit {
        switch self {
        case .count:
            return HKUnit.count()
        }
    }
}

#endif
