//
//  HealthKitAuthorizor+AuthorizableBiometric.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import HealthKit
import Core

// MARK: - HealthKitAuthorizor and AuthorizableBiometric

@available(iOS 13.0, macOS 13.0, watchOS 9.0, *)
public extension HealthKitAuthorizor {
    
    /// Determines whether requesting authorization for the given types is necessary.
    ///
    /// Applications may call this method to determine whether the user would be prompted for authorization if
    /// the same collections of types are passed to requestAuthorizationToShareTypes:readTypes:completion:.
    /// This determination is performed asynchronously and its completion will be executed on an arbitrary
    /// background queue.
    func getRequestStatusForAuthorization(
        toShare typesToShare: [AuthorizableBiometric],
        read typesToRead: [AuthorizableBiometric],
        completion: @escaping (RequestStatusResult) -> Void
    ) {
        
        guard self.isHealthDataAvailable else {
            completion(.error(HealthKitAuthorizorError.healthDataNotAvailable))
            return
        }
        
        do {
            let toShare: Set<HKSampleType> = Set(try typesToShare.map { biometric in
                let biometric = try CodableHealthBiometric(identifier: biometric.healthKitIdentifier)
                return biometric.sampleType
            })
            let toRead: Set<HKSampleType> = Set(try typesToRead.map { biometric in
                let biometric = try CodableHealthBiometric(identifier: biometric.healthKitIdentifier)
                return biometric.sampleType
            })
            self.getRequestStatusForAuthorization(toShare: toShare, read: toRead) { status, error in
                if let error {
                    completion(.error(error))
                } else {
                    completion(.success(status: status))
                }
            }
        } catch {
            completion(.error(error))
        }
    }
    
    /// Determines whether requesting authorization for the given types is necessary.
    ///
    /// Applications may call this method to determine whether the user would be prompted for authorization if
    /// the same collections of types are passed to requestAuthorizationToShareTypes:readTypes:completion:.
    /// This determination is performed asynchronously and its completion will be executed on an arbitrary
    /// background queue.
    func getRequestStatusForAuthorization(
        toShare typesToShare: [AuthorizableBiometric],
        read typesToRead: [AuthorizableBiometric]
    ) async throws -> HKAuthorizationRequestStatus {
        return try await withCheckedThrowingContinuation { continuation in
            self.getRequestStatusForAuthorization(
                toShare: typesToShare,
                read: typesToRead
            ) { result in
                switch result {
                case .error(let error):
                    continuation.resume(throwing: error)
                case .success(status: let status):
                    continuation.resume(returning: status)
                }
            }
        }
    }
    
    /// Prompts the user to authorize the application for reading and saving objects of the given types.
    ///
    /// Before attempting to execute queries or save objects, the application should first request authorization
    /// from the user to read and share every type of object for which the application may require access.
    ///
    /// The request is performed asynchronously and its completion will be executed on an arbitrary background
    /// queue after the user has responded.  If the user has already chosen whether to grant the application
    /// access to all of the types provided, then the completion will be called without prompting the user.
    /// The success parameter of the completion indicates whether prompting the user, if necessary, completed
    /// successfully and was not cancelled by the user.  It does NOT indicate whether the application was
    /// granted authorization.
    ///
    /// To customize the messages displayed on the authorization sheet, set the following keys in your app's
    /// Info.plist file. Set the NSHealthShareUsageDescription key to customize the message for reading data.
    /// Set the NSHealthUpdateUsageDescription key to customize the message for writing data.
    ///
    /// - Warning: You must set the usage keys, or your app will crash when you request authorization.
    /// For projects created using Xcode 13 or later, set these keys in the Target Properties list on the app’s Info tab.
    /// For projects created with Xcode 12 or earlier, set these keys in the apps Info.plist file. For more
    /// information, see Information Property List.
    ///
    /// After users have set the permissions for your app, they can always change them using either the Settings or
    /// the Health app. Your app appears in the Health app’s Sources tab, even if the user didn’t allow permission to
    /// read or share data.
    func requestAuthorization(
        toShare typesToShare: [AuthorizableBiometric],
        read typesToRead: [AuthorizableBiometric],
        completion: @escaping (RequestAuthorizationResult) -> Void
    ) {
        
        guard self.isHealthDataAvailable else {
            completion(.error(HealthKitAuthorizorError.healthDataNotAvailable))
            return
        }
        
        do {
            let toShare: Set<HKSampleType> = Set(try typesToShare.map { biometric in
                let biometric = try CodableHealthBiometric(identifier: biometric.healthKitIdentifier)
                return biometric.sampleType
            })
            let toRead: Set<HKSampleType> = Set(try typesToRead.map { biometric in
                let biometric = try CodableHealthBiometric(identifier: biometric.healthKitIdentifier)
                return biometric.sampleType
            })
            self.requestAuthorization(
                toShare: toShare,
                read: toRead
            ) { success, error in
                if let error {
                    completion(.error(error))
                } else {
                    completion(.success)
                }
            }
        } catch {
            completion(.error(error))
        }
    }

    /// Prompts the user to authorize the application for reading and saving objects of the given types.
    ///
    /// Before attempting to execute queries or save objects, the application should first request authorization
    /// from the user to read and share every type of object for which the application may require access.
    ///
    /// The request is performed asynchronously and its completion will be executed on an arbitrary background
    /// queue after the user has responded.  If the user has already chosen whether to grant the application
    /// access to all of the types provided, then the completion will be called without prompting the user.
    /// The success parameter of the completion indicates whether prompting the user, if necessary, completed
    /// successfully and was not cancelled by the user.  It does NOT indicate whether the application was
    /// granted authorization.
    ///
    /// To customize the messages displayed on the authorization sheet, set the following keys in your app's
    /// Info.plist file. Set the NSHealthShareUsageDescription key to customize the message for reading data.
    /// Set the NSHealthUpdateUsageDescription key to customize the message for writing data.
    ///
    /// - Warning: You must set the usage keys, or your app will crash when you request authorization.
    /// For projects created using Xcode 13 or later, set these keys in the Target Properties list on the app’s Info tab.
    /// For projects created with Xcode 12 or earlier, set these keys in the apps Info.plist file. For more
    /// information, see Information Property List.
    ///
    /// After users have set the permissions for your app, they can always change them using either the Settings or
    /// the Health app. Your app appears in the Health app’s Sources tab, even if the user didn’t allow permission to
    /// read or share data.
    func requestAuthorization(
        toShare typesToShare: [AuthorizableBiometric],
        read typesToRead: [AuthorizableBiometric]
    ) async throws {
        return try await withCheckedThrowingVoidContinuation { continuation in
            self.requestAuthorization(
                toShare: typesToShare,
                read: typesToRead
            ) { result in
                switch result {
                case .error(let error):
                    continuation.resume(throwing: error)
                case .success:
                    continuation.resume()
                }
            }
        }
    }
}
