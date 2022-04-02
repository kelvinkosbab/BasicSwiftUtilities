//
//  AppState.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Protocols

/// A protocol that defines the definition for objects that register objects to listen to app state changes.
public protocol AppStateListenerRegistrar {
    func register(_ listener: AppStateListener) -> () -> Void
}

/// Protocol defining an object that provides app state listener contexts.
public protocol AppStateListenerProvider {

    /// A list of all listeners that are registered to app state changes.
    var listeners: [AppStateListener] { get }
}

// MARK: - AppState

/// Structure to manage listeners to app state changes.
public class AppState: AppStateListenerRegistrar, AppStateListenerProvider {

    /// Singleton reference.
    public static let shared = AppState()
    internal init() {}

    /// Serial queue to insure thread safe reads and writes to `unserializedWeakListeners`.
    private let serialQueue = DispatchQueue(label: "AppStateQueue", target: .global())
    
    /// Logger.
    private let logger = Logger(subsystem: "Core.AppState", category: "AppState")

    /// Returns a set of weak listeners. Do not call this method outside a closure of the `serialQueue`.
    private var unserializedWeakListeners: Set<WeakListener> = Set()

    /// Registers an `AppStateListener`. The provided objet will be able to subscribe to various app state events.
    ///
    ///- Note:
    /// - When you a register an `AppStateListener`, you are _also_ responsible for holding onto a strong reference to
    /// that listener so that it doesn't go out of scope. This class doesn't hold onto strong references to avoid causing retain cycles.
    /// - It is recommended you deregister from app state events whenever it is unnessary to the function of your module. Failing
    /// to deregister results in wasted work being done at a period critical to the app's performance.
    /// - Registering multiple times will result in callbacks being called multiple times.
    /// - Timing metrics are automatically recorded for the listener hook. The method name will be the `AppStateListener`
    /// function name pre-appended by the `moduleName`.
    /// Example: `{module_name}.appForegrounded`
    ///
    /// Usage:
    /// ```
    /// // Conform to AppStateListener and add desired app state hooks.
    /// class MyClass: AppStateListener {
    ///
    ///     let moduleName = "MyModule"
    ///     let dispatchQueue: DispatchGroup = .global(qos: .utility) // Optional
    ///     let metrics = ServiceCoreMetrics(...)
    ///
    ///     func appForegrounded() {
    ///         // do your foreground work
    ///     }
    /// }
    ///
    /// // Register your class.
    /// let myClass = MyClass()
    /// let deregister = AppState.shared.register(self)
    ///
    /// // Deregistering your listener
    /// deregister()
    /// ```
    ///
    /// - Parameter listener: The object registering to app state events.
    ///
    /// - Returns: A closure to deregister from app state events.
    public func register(_ listener: AppStateListener) -> () -> Void {
        self.logger.debug("\(listener.moduleName) has registered for AppState changes.")
        let weakListener = WeakListener(listener: listener)
        self.serialQueue.async {
            self.unserializedWeakListeners.insert(weakListener)
        }
        return {
            self.logger.debug("\(listener.moduleName) has deregistered from AppState changes.")
            self.serialQueue.async {
                self.unserializedWeakListeners.remove(weakListener)
            }
        }
    }

    /// A list of all listeners that are registered to app state changes.
    ///
    /// - Because there is no way to be notified for weak references when they are released, we must first
    /// sanitize the `weakListeners` by removing all the `WeakListener`s where the listener
    /// reference is `nil`.
    ///
    /// - Returns: An array of app state listeners.
    public var listeners: [AppStateListener] {
        return self.serialQueue.sync {
            var listenersToDeregister: [WeakListener] = []
            var listenersToReturn: [AppStateListener] = []
            for weakListener in self.unserializedWeakListeners {
                if let strongListener = weakListener.listener {
                    listenersToReturn.append(strongListener)
                } else {
                    listenersToDeregister.append(weakListener)
                }
            }

            /// Sanitize the current `WeakListener`s
            for weakListener in listenersToDeregister {
                self.unserializedWeakListeners.remove(weakListener)
            }

            return listenersToReturn
        }
    }

    // MARK: - WeakListener

    /// Structure to hold a weak reference of an `AppStateListener`.
    private struct WeakListener: Hashable {

        /// Unique identifier for this object.
        let uuid = UUID()

        /// Weak reference to the object listening to app state changes.
        ///
        /// - This is a weak reference so any object that registers for events is not retained by the `AppState` object.
        /// - When the listener is released from memory unfotunately the `didSet` callback is not called.
        /// - To check if the listener has been released, simply check this property (`== nil`)
        weak var listener: AppStateListener?

        /// Constructor.
        ///
        /// - Parameter listener: Weak reference to the object listening to app state changes.
        init(listener: AppStateListener) {
            self.listener = listener
        }

        // Hashable
        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.uuid)
        }

        // Equatable
        public static func == (lhs: WeakListener, rhs: WeakListener) -> Bool {
            return lhs.uuid == rhs.uuid && (lhs.listener == nil) == (rhs.listener == nil)
        }
    }
}
