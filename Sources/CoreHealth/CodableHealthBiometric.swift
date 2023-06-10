//Biometric.swift
//
//  Created by Kelvin Kosbab on 4/3/22.
//

import Foundation
import HealthKit

// MARK: - CodableHealthBiometricType

/// An abstract type for all classes that identify a specific type of sample when working with the HealthKit store.
///
/// https://developer.apple.com/documentation/healthkit/hksampletype
enum CodableHealthBiometricType : Int {
    
    /// A type that identifies samples that store numerical values.
    ///
    /// https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier
    case quantity = 0
    
    /// A type that identifies samples that contain a value from a small set of possible values.
    ///
    /// https://developer.apple.com/documentation/healthkit/hkcategorytypeidentifier
    case category = 1
    
    /// A type that identifies samples that group multiple subsamples.
    ///
    /// https://developer.apple.com/documentation/healthkit/hkcorrelationtypeidentifier
    case correlation = 2
    
    /// The identifiers for documents.
    ///
    /// https://developer.apple.com/documentation/healthkit/hkdocumenttypeidentifier
    case document = 3
    
    /// A type that identifies samples that store information about a workout.
    ///
    /// https://developer.apple.com/documentation/healthkit/hkworkouttype
    case workout = 4
}

/// Helper object to define a wokrout identifier type.
public enum WorkoutTypeIdentifier : String {
    
    /// This method returns an instance of the HKWorkoutType concrete subclass. HealthKit uses workout types to create
    /// samples that store information about individual workouts. Use workout type instances to create workout objects that
    /// you can save in the HealthKit store. For more information, see `HKWorkoutType`.
    ///
    /// In HealthKit, all workouts use the same workout type.
    case workout = "WorkoutTypeIdentifier"
}

// MARK: - CodableHealthBiometric

@available(macOS 13.0, *)
struct CodableHealthBiometric {
    
    // MARK: - Properties
    
    let identifier: String
    let biometricType: CodableHealthBiometricType
    let sampleType: HKSampleType
    
    // MARK: - InitError
    
    enum InitError : Error, LocalizedError {
        
        /// Error thrown when an identifier does not correspond to a HealthKit type.
        ///
        /// Causes:
        /// - `HKObjectType.quantityType(forIdentifier: identifier) // returns nil`
        /// - `HKObjectType.categoryType(forIdentifier: identifier) // returns nil`
        /// - `HKObjectType.correlationType(forIdentifier: identifier) // returns nil`
        /// - `HKObjectType.documentType(forIdentifier: identifier) // returns nil`
        case undefinedHKObjectType(identifier: String)
        
        var errorDescription: String? {
            switch self {
            case .undefinedHKObjectType(identifier: let identifier):
                return "Failed to create a HKObjectType with identifier=\(identifier)"
            }
        }
    }
    
    // MARK: - Public Init
    
    /// Initializes a quantity type.
    ///
    /// - Throws if the identifier is not valid in HealthKit.
    public init(
        identifier: HKQuantityTypeIdentifier
    ) throws {
        try self.init(
            identifier: identifier.rawValue,
            biometricType: .quantity
        )
    }
    
    /// Initializes a category type.
    ///
    /// - Throws if the identifier is not valid in HealthKit.
    public init(
        identifier: HKCategoryTypeIdentifier
    ) throws {
        try self.init(
            identifier: identifier.rawValue,
            biometricType: .category
        )
    }
    
    /// Initializes a quantity type.
    ///
    /// - Throws if the identifier is not valid in HealthKit.
    public init(
        identifier: HKCorrelationTypeIdentifier
    ) throws {
        try self.init(
            identifier: identifier.rawValue,
            biometricType: .correlation
        )
    }
    
    /// Initializes a document type.
    ///
    /// - Throws if the identifier is not valid in HealthKit.
    public init(
        identifier: HKDocumentTypeIdentifier
    ) throws {
        try self.init(
            identifier: identifier.rawValue,
            biometricType: .document
        )
    }
    
    /// Initializes a workout type.
    ///
    /// - Throws if the identifier is not valid in HealthKit.
    public init(
        identifier: WorkoutTypeIdentifier
    ) throws {
        try self.init(
            identifier: identifier.rawValue,
            biometricType: .workout
        )
    }
    
    // MARK: - Private Init
    
    private init(
        identifier: String,
        biometricType: CodableHealthBiometricType
    ) throws {
        switch biometricType {
        case .quantity:
            let sampleIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
            let sampleType = HKObjectType.quantityType(forIdentifier: sampleIdentifier)
            try self.init(
                identifier: identifier,
                biometricType: biometricType,
                sampleType: sampleType
            )
        case .category:
            let sampleIdentifier = HKCategoryTypeIdentifier(rawValue: identifier)
            let sampleType = HKObjectType.categoryType(forIdentifier: sampleIdentifier)
            try self.init(
                identifier: identifier,
                biometricType: biometricType,
                sampleType: sampleType
            )
        case .correlation:
            let sampleIdentifier = HKCorrelationTypeIdentifier(rawValue: identifier)
            let sampleType = HKObjectType.correlationType(forIdentifier: sampleIdentifier)
            try self.init(
                identifier: identifier,
                biometricType: biometricType,
                sampleType: sampleType
            )
        case .document:
            let sampleIdentifier = HKDocumentTypeIdentifier(rawValue: identifier)
            let sampleType = HKObjectType.documentType(forIdentifier: sampleIdentifier)
            try self.init(
                identifier: identifier,
                biometricType: biometricType,
                sampleType: sampleType
            )
        case .workout:
            try self.init(
                identifier: identifier,
                biometricType: biometricType,
                sampleType: HKObjectType.workoutType()
            )
        }
    }
    
    private init(
        identifier: String,
        biometricType: CodableHealthBiometricType,
        sampleType: HKSampleType?
    ) throws {
        
        guard let sampleType else {
            throw InitError.undefinedHKObjectType(identifier: identifier)
        }
        
        self.identifier = identifier
        self.biometricType = biometricType
        self.sampleType = sampleType
    }
}
