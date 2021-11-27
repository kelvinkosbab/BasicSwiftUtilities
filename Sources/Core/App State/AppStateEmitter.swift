//
//  AppStateEmitter.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

/// Protocol that defines responsibilities for objects that notify app state changes to listeners.
///
/// - When app state listener hooks are called, they are done so asyncronously on different `utility`
/// dispatch queues. This prevents one hook from blocking another hook.
public protocol AppStateEmitter {
    
    /// Provides app state listener contexts to signal.
    var appStateContextsProvider: AppStateListenerProvider { get }
}

public extension AppStateEmitter {

    /// Signals all `AppState` listeners' `appForeground` hook.
    ///
    /// - Each hook will be executed asyncronously on the `AppStateListener`'s provided thread.
    /// - Timing metrics are recorded on the `AppStateListener`'s provided metric provider.
    func signalForegroundListeners() {
        for listener in self.appStateContextsProvider.listeners {
            listener.dispatchQueue.async {
                listener.logger.debug("\(listener.moduleName) is executing `appForegrounded`")
                listener.appForegrounded()
            }
        }
    }

    /// Signals all `AppState` listeners' `appBackgrounded` hook.
    ///
    /// - Each hook will be executed asyncronously on the `AppStateListener`'s provided thread.
    /// - Timing metrics are recorded on the `AppStateListener`'s provided metric provider.
    func signalBackgroundListeners() {
        for listener in self.appStateContextsProvider.listeners {
            listener.dispatchQueue.async {
                listener.logger.debug("\(listener.moduleName) is executing `appBackgrounded`")
                listener.appBackgrounded()
            }
        }
    }
}
