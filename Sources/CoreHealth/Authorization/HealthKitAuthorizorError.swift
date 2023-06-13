//
//  HealthKitAuthorizorError.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - HealthKitAuthorizorError

/// Errors thrown when authorizing the status of a given biometric.
public enum HealthKitAuthorizorError : Swift.Error {
    
    /// Thrown when a health data is not available on the device.
    case healthDataNotAvailable
    
    /// Thrown when there is a new and unhandled case in the `HKAuthorizationRequestStatus` type.
    case unsupportedRequestStatusForAuthorizationStatus
    
    /// An error thrown if the request for authoration failed.
    case failedToRequestAuthorization
}

