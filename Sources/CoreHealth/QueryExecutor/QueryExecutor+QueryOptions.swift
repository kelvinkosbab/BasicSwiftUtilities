//
//  QueryExecutor+QueryOptions.swift
//
//  Created by Kelvin Kosbab on 10/2/22.
//

import HealthKit

// MARK: - QueryExecutor and QueryOptions

@available(iOS 13.0, macOS 13.0, watchOS 8.0, *)
public extension QueryExecutor {
    
    /// After executing a query, the completion, update, and/or results handlers of that query will be invoked
    /// asynchronously on an arbitrary background queue as results become available.  Errors that prevent a
    /// query from executing will be delivered to one of the query's handlers.  Which handler the error will be
    /// delivered to is defined by the `HKQuery` subclass.
    ///
    /// Each HKQuery instance may only be executed once and calling this method with a currently executing query
    /// or one that was previously executed will result in an exception.
    ///
    /// If a query would retrieve objects with an `HKObjectType` property, then the application must request
    /// authorization to access objects of that type before executing the query.
    ///
    /// - Parameter sampleType: Biometric type to query.
    /// - Parameter options: Query options to apply to the query
    /// - Parameter completion: Completion handler when the query requests has completed.
    ///
    /// - Returns samples representing measurements taken over a period of time.
    func query(
        _ sampleType: HKSampleType,
        options: QueryOptions,
        completion: @escaping (_ result: HKQuantitySampleResult) -> Void
    ) {
        
        let predicate = HKQuery.predicateForSamples(
            withStart: options.startDate,
            end: options.endDate
        )
        
        self.query(
            sampleType: sampleType,
            predicate: predicate,
            limit: options.limit.rawValue,
            sortDescriptors: options.sortDescriptors ?? [
                NSSortDescriptor(
                    key: HKSampleSortIdentifierStartDate,
                    ascending: false
                )
            ]
        ) { _, samples, error in
            
            guard let samples else {
                if let error {
                    completion(.error(error))
                } else {
                    completion(.success(samples: []))
                }
                return
            }
            
            guard let quantitySamples = samples as? [HKQuantitySample] else {
                completion(.error(QueryError.unsupportedSampleType(samples: samples)))
                return
            }
            
            completion(.success(samples: quantitySamples))
        }
    }
    
    /// After executing a query, the completion, update, and/or results handlers of that query will be invoked
    /// asynchronously on an arbitrary background queue as results become available.  Errors that prevent a
    /// query from executing will be delivered to one of the query's handlers.  Which handler the error will be
    /// delivered to is defined by the `HKQuery` subclass.
    ///
    /// Each HKQuery instance may only be executed once and calling this method with a currently executing query
    /// or one that was previously executed will result in an exception.
    ///
    /// If a query would retrieve objects with an `HKObjectType` property, then the application must request
    /// authorization to access objects of that type before executing the query.
    ///
    /// - Parameter sampleType: Biometric type to query.
    /// - Parameter options: Query options to apply to the query.
    ///
    /// - Returns samples representing measurements taken over a period of time.
    func query(
        _ sampleType: HKSampleType,
        options: QueryOptions
    ) async throws -> [HKQuantitySample] {
        return try await withCheckedThrowingContinuation { continuation in
            self.query(
                sampleType,
                options: options
            ) { result in
                switch result {
                case .error(let error):
                    continuation.resume(throwing: error)
                case .success(samples: let samples):
                    continuation.resume(returning: samples)
                }
            }
        }
    }
}
