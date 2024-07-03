//
//  Biometric.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import HealthKit

// MARK: - Biometric

public protocol Biometric: Hashable {

    associatedtype UnitofMeasurement: Unit

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

#endif
