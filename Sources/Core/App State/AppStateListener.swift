//
//  AppStateListener.swift
//
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

/// Protocol that defines API for objects that listen to application state events.
///
/// - Note: If additional methods are added to this protocol there should be a default no-op implementation
/// to support backwards compatibility.
public protocol AppStateListener : AnyObject {

    /// Dispatch queue the lifecycle events will run on..
    var dispatchQueue: DispatchQueue { get }

    /// Name of the module listening for app state changes. This should be alphanumeric.
    /// This name will be included in metrics emitted related to app state changes.
    var moduleName: String { get }
    
    /// Logger.
    var logger: Logger { get }

    /// The app moves to the foreground state because it was launched by the user or the system,
    /// or because the user ignores an interruption (like an incoming phone call or SMS message)
    /// that sent the app temporarily to the foreground state.
    ///
    /// Restart any tasks that were paused (or not yet started) while the application was
    /// inactive. If the application was previously in the background, optionally refresh the
    /// user interface.
    ///
    /// - Note: This method will be called when the app launches to the foreground. It is also called
    /// after exiting from the control panel or the notification menu if Halo was the last app in the foreground.
    func appForegrounded()

    /// The app moves to the background when the user chooses to navigate to the iOS home screen or if the
    /// user locks the phone. Stop any tasks that are in progress.
    ///
    /// For UIKit applications this method is triggererd from the `UIApplicationDelegate`'s `applicationDidEnterBackground`.
    /// https://developer.apple.com/documentation/uikit/uiapplicationdelegate
    ///
    /// For SwiftUI applications this method is triggered from an on change listener on the `Scene` phase.
    /// https://developer.apple.com/documentation/swiftui/scene
    func appBackgrounded()
}

/// Defaults.
public extension AppStateListener {

    /// No-op by default.
    func appForegrounded() {}
    func appBackgrounded() {}
}
