//
//  HealthKitAuthorizor.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import Foundation
import HealthKit
import Core

// MARK: - HealthKitAuthorizor

@available(macOS 13.0, watchOS 5.0, *)
public protocol HealthKitAuthorizor : HealthKitSupported {
    
    /// Determines whether requesting authorization for the given types is necessary.
    ///
    /// Applications may call this method to determine whether the user would be prompted for authorization if
    /// the same collections of types are passed to requestAuthorizationToShareTypes:readTypes:completion:.
    /// This determination is performed asynchronously and its completion will be executed on an arbitrary
    /// background queue.
    func getRequestStatusForAuthorization(
        toShare typesToShare: Set<HKSampleType>,
        read typesToRead: Set<HKObjectType>,
        completion: @escaping (HKAuthorizationRequestStatus, Error?) -> Void
    )
    
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
    ///
    /// - Parameter typesToShare: A set containing the data types you want to share. This set can contain any
    /// concrete subclass of the `HKSampleType` class (any of the `HKQuantityType`, `HKCategoryType`,
    /// `HKWorkoutType`, or `HKCorrelationType` classes ). If the user grants permission, your app can create
    /// and save these data types to the HealthKit store.
    ///
    /// - Parameter typesToRead: A set containing the data types you want to read. This set can contain any
    /// concrete subclass of the `HKObjectType` class (any of the `HKCharacteristicType` ,
    /// `HKQuantityType`, `HKCategoryType`, `HKWorkoutType`, or `HKCorrelationType` classes). If
    /// the user grants permission, your app can read these data types from the HealthKit store.
    /// - Parameter completion: A block called after the user finishes responding to the request. The system
    /// calls this block with the following parameters
    ///   - Parameter success: A Boolean value that indicates whether the request succeeded. This value doesn’t
    ///   indicate whether the user actually granted permission. The parameter is false if an error occurred while
    ///   processing the request; otherwise, it’s true.
    ///   - Parameter error: An error object. If an error occurred, this object contains information about the error;
    ///   otherwise, it’s set to nil.
    func requestAuthorization(
        toShare typesToShare: Set<HKSampleType>?,
        read typesToRead: Set<HKObjectType>?,
        completion: @escaping (Bool, Error?) -> Void
    )
}

// MARK: - HKHealthStore

@available(macOS 13.0, *)
extension HKHealthStore : HealthKitAuthorizor {}

#endif
