//
//  QueryOptions.swift
//
//  Created by Kelvin Kosbab on 8/3/22.
//

import Foundation
import HealthKit

/// An object that provides configuration options for a Health Store query.
@available(macOS 13.0, *)
public struct QueryOptions {
    
    /// Defines the maximum number of results the receiver will return upon completion.
    public enum Limit {
        
        /// The query returns all samples that match the given sampleType and predicate.
        case noLimit
        
        /// The query returns the limit of samples specified from the `max` parameter.
        case limit(_ max: Int)
        
        /// The maximum number of results the receiver will return upon completion.
        var rawValue: Int {
            switch self {
            case .limit(let limit):
                return limit
            case .noLimit:
                return HKObjectQueryNoLimit
            }
        }
    }
    
    /// The start date limit of the query.
    ///
    /// If all health data is desired consider using `Date.distantPast`.
    let startDate: Date
    
    /// The end date limit of the query.
    let endDate: Date
    
    /// The maximum number of results the receiver will return upon completion.
    let limit: Limit
    
    /// An array of NSSortDescriptors.
    ///
    /// Consider these key paths for predicates:
    /// - `HKPredicateKeyPathQuantity`: The key path for accessing the sample’s quantity.
    /// - `HKPredicateKeyPathCount`: A key path for the sample’s count.
    let sortDescriptors: [NSSortDescriptor]?
    
    /// Constructor.
    ///
    /// - Parameter startDate: The start date limit of the query. If all health data is desired consider using `Date.distantPast`.
    /// - Parameter endDate: The end date limit of the query.
    /// - Parameter limit: The maximum number of results the receiver will return upon completion.
    /// - Parameter sortDescriptors: An array of NSSortDescriptors. Consider these key paths for predicates.
    ///   `HKPredicateKeyPathQuantity`: The key path for accessing the sample’s quantity.
    ///   `HKPredicateKeyPathCount`: A key path for the sample’s count.
    public init(
        startDate: Date,
        endDate: Date,
        limit: Limit = .noLimit,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.limit = limit
        self.sortDescriptors = sortDescriptors
    }
}
