//
//  AuthorizableBiometric.swift
//
//  Created by Kelvin Kosbab on 10/6/22.
//

import HealthKit

// MARK: - AuthorizableBiometric

@available(iOS 13.0, macOS 13.0, watchOS 9.0, *)
public enum AuthorizableBiometric : Hashable {
    case cardioFitness(CardioFitnessBiometric)
    case energy(EnergyBiometric)
    case length(LengthBiometric)
    case rate(RateBiometric)
    case temperature(TemperatureBiometric)
    case time(TimeBiometric)
    
    public var healthKitIdentifier: HKQuantityTypeIdentifier {
        switch self {
        case .cardioFitness(let biometric):
            return biometric.healthKitIdentifier
        case .energy(let biometric):
            return biometric.healthKitIdentifier
        case .length(let biometric):
            return biometric.healthKitIdentifier
        case .rate(let biometric):
            return biometric.healthKitIdentifier
        case .temperature(let biometric):
            return biometric.healthKitIdentifier
        case .time(let biometric):
            return biometric.healthKitIdentifier
        }
    }
}
