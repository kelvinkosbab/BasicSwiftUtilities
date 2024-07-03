//
//  QueryExecutor+HKSampleQuery.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import HealthKit

// MARK: - QueryExecutor and HKSampleQuery

@available(macOS 13.0, watchOS 8.0, *)
public extension QueryExecutor {

    /// Queries HKSamples matching the given predicate.
    ///
    /// - Parameter sampleType: The type of sample to retrieve.
    /// - Parameter predicate: The predicate which samples should match.
    /// - Parameter limit: The maximum number of samples to return.  Pass HKObjectQueryNoLimit for no limit.
    /// - Parameter sortDescriptors: The sort descriptors to use to order the resulting samples.
    /// - Parameter resultsHandler: The block to invoke with results when the query has finished executing.
    func query(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?,
        resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void
    ) {

        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors,
            resultsHandler: resultsHandler
        )

        self.execute(query)
    }

    /// Queries HKSamples matching the given predicate.
    ///
    /// - Parameter sampleType: The type of sample to retrieve.
    /// - Parameter predicate: The predicate which samples should match.
    /// - Parameter limit: The maximum number of samples to return.  Pass HKObjectQueryNoLimit for no limit.
    /// - Parameter sortDescriptors: The sort descriptors to use to order the resulting samples.
    func query(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?
    ) async throws -> [HKSample] {
        return []
    }

    /// Queries  HKSamples matching any of the given queryDescriptors.
    ///
    /// - Parameter queryDescriptors: An array of query descriptors that describes the sample types and predicates
    /// used for querying.
    /// - Parameters limit: The maximum number of samples to return. Pass HKObjectQueryNoLimit
    /// for no limit.
    /// - Parameters resultsHandler: The block to invoke with results when the query has finished executing. This
    /// block is invoked once with results, an array of HKSamples matching the
    /// queryDescriptors passed in, or nil if an error occurred.
    @available(iOS 15.0, *)
    func query(
        queryDescriptors: [HKQueryDescriptor],
        limit: Int,
        resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void
    ) {

        let query = HKSampleQuery(
            queryDescriptors: queryDescriptors,
            limit: limit,
            resultsHandler: resultsHandler
        )

        self.execute(query)
    }

    /// Queries  HKSamples matching any of the given queryDescriptors.
    ///
    /// - Parameter queryDescriptors: An array of query descriptors that describes the sample types and predicates
    /// used for querying.
    /// - Parameters limit: The maximum number of samples to return. Pass HKObjectQueryNoLimit
    /// for no limit.
    @available(iOS 15.0, *)
    func query(
        queryDescriptors: [HKQueryDescriptor],
        limit: Int
    ) async throws -> [HKSample] {
        return []
    }

    /// Queries HKSamples matching any of the given queryDescriptors.
    ///
    /// - Parameter queryDescriptors: An array of query descriptors that describes the sample types and predicates
    /// used for querying.
    /// - Parameter limit: The maximum number of samples to return. Pass HKObjectQueryNoLimit
    /// for no limit.
    /// - Parameter sortDescriptors: The sort descriptors to use to order the resulting samples.
    /// - Parameter resultsHandler: The block to invoke with results when the query has finished executing. This
    /// block is invoked once with results, an array of HKSamples matching the
    /// queryDescriptors passed in, or nil if an error occurred. The HKSamples in the
    /// array are sorted by the specified sortDescriptors.
    @available(iOS 15.0, *)
    func query(
        queryDescriptors: [HKQueryDescriptor],
        limit: Int,
        sortDescriptors: [NSSortDescriptor],
        resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void
    ) {

        let query = HKSampleQuery(
            queryDescriptors: queryDescriptors,
            limit: limit,
            sortDescriptors: sortDescriptors,
            resultsHandler: resultsHandler
        )

        self.execute(query)
    }

    /// Queries HKSamples matching any of the given queryDescriptors.
    ///
    /// - Parameter queryDescriptors: An array of query descriptors that describes the sample types and predicates
    /// used for querying.
    /// - Parameter limit: The maximum number of samples to return. Pass HKObjectQueryNoLimit
    /// for no limit.
    /// - Parameter sortDescriptors: The sort descriptors to use to order the resulting samples.
    @available(iOS 15.0, *)
    func query(
        queryDescriptors: [HKQueryDescriptor],
        limit: Int,
        sortDescriptors: [NSSortDescriptor]
    ) async throws -> [HKSample] {
        return []
    }
}

#endif
