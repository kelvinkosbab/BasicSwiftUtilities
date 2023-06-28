//
//  QueryExecutor+HKQuantityTypeIdentifier.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import HealthKit

// MARK: - QueryExecutor and HKQuantityTypeIdentifier

@available(iOS 13.0, macOS 13.0, watchOS 8.0, *)
internal extension QueryExecutor {
    
    /// Internal helper function for fetching samples for a given quantity type for a given unit.
    func query(
        identifier healthKitIdentifier: HKQuantityTypeIdentifier,
        unit: Unit,
        options: QueryOptions,
        completion: @escaping (_ result: HKQuantitySampleResult) -> Void
    ) {
        do {
            let biometric = try CodableHealthBiometric(identifier: healthKitIdentifier)
            self.query(biometric.sampleType, options: options) { result in
                
                switch result {
                case .error(let error):
                    completion(.error(error))
                case .success(samples: let samples):
                    
                    for sample in samples {
                        if !sample.quantityType.is(compatibleWith: unit.healthKitUnit) {
                            let error = QueryError.unitIncompatibleWithQuantityType(
                                quantityType: sample.quantityType, desiredUnit: unit.healthKitUnit
                            )
                            completion(.error(error))
                            return
                        }
                    }
                    
                    completion(.success(samples: samples))
                }
            }
        } catch {
            completion(.error(error))
        }
    }
    
    /// Internal helper function for fetching samples for a given quantity type for a given unit.
    func query(
        identifier healthKitIdentifier: HKQuantityTypeIdentifier,
        unit: Unit,
        options: QueryOptions
    ) async throws -> [Sample] {
        let biometric = try CodableHealthBiometric(identifier: healthKitIdentifier)
        let samples = try await self.query(biometric.sampleType, options: options)
        return try samples.map { sample in
            
            guard sample.quantityType.is(compatibleWith: unit.healthKitUnit) else {
                throw QueryError.unitIncompatibleWithQuantityType(
                    quantityType: sample.quantityType, desiredUnit: unit.healthKitUnit
                )
            }
            
            return Sample(
                startDate: sample.startDate,
                endDate: sample.endDate,
                value: sample.quantity.doubleValue(for: unit.healthKitUnit),
                unit: unit
            )
        }
    }
}

#endif
