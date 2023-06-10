//
//  Biometric.swift
//
//  Created by Kelvin Kosbab on 9/17/22.
//

import HealthKit

// MARK: - Biometric

public protocol Biometric : Hashable {
    
    associatedtype UnitofMeasurement : Unit
    
    static var Units: UnitofMeasurement.Type { get }
    
    var healthKitIdentifier: HKQuantityTypeIdentifier { get }
}

// MARK: - Hashable

public extension Biometric {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.healthKitIdentifier)
    }
    
    static func == (lhs: any Biometric, rhs: any Biometric) -> Bool {
        return lhs.healthKitIdentifier == rhs.healthKitIdentifier
    }
}
