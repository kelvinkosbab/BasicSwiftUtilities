//
//  HKQuantitySampleResult.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import HealthKit

// MARK: - HKQuantitySampleResult

/// Defines an object that a query returns after executing.
@available(macOS 13.0, *)
public enum HKQuantitySampleResult {
    
    /// An error was thrown during the query.
    ///
    /// - Parameter error: Error encountered during query.
    case error(_ error: Error)
    
    /// The query completed successfully.
    ///
    /// - Parameter samples: The samples returned from the query.
    case success(samples: [HKQuantitySample])
}

#endif
