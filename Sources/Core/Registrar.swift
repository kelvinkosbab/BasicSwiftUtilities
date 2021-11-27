//
//  Registrar.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Protocols

public protocol RegisteredObject : AnyObject, Hashable {
    /// Name of the registered module. This should be alphanumeric.
    var moduleName: String { get }
}

/// A protocol for objects that register objects.
public protocol Registrar {
    associatedtype T : RegisteredObject
    func register(_ object: T) -> Void
    func deregister(_ object: T)
}

/// Protocol for objects that provides a list of objects that are registered.
public protocol RegisterProvider {
    associatedtype T : RegisteredObject
    var objects: Set<T> { get }
}

// MARK: - ObjectRegistrar

/// Object to manage registering objects.
open class ObjectRegistrar<T> : Registrar, RegisterProvider where T: RegisteredObject {
    
    /// Constructor.
    public init() {}
    
    /// Serial queue to insure thread safe reads and writes to `unserializedWeakListeners`.
    private let serialQueue = DispatchQueue(label: "ObjectRegistrar.\(String(describing: T.self))", target: .global())
    
    /// Logger.
    private let logger = Logger(subsystem: "Core.ObjectRegistrar", category: "ObjectRegistrar.\(String(describing: T.self))")
    
    /// Returns a set of weak object. Do not call this method outside a closure of the `serialQueue`.
    private var unserializedWeakObjects: Set<WeakObject<T>> = Set()
    
    /// Registers an object.
    ///
    ///- Note:
    /// - When you a register an object, you are _also_ responsible for holding onto a strong reference to
    /// that object so that it doesn't go out of scope. This class doesn't hold onto strong references to avoid causing retain cycles.
    /// - It is recommended you deregister whenever it is unnessary to the function of your module. Failing
    /// to deregister results in wasted work being done at a period critical to the app's performance.
    /// - Registering multiple times will result in callbacks being called multiple times.
    ///
    /// - Parameter listener: The object registering to app state events.
    public func register(_ object: T) -> Void {
        self.logger.debug("\(object.moduleName) has been registerd.")
        let weakObject = WeakObject(object: object)
        self.serialQueue.async {
            self.unserializedWeakObjects.insert(weakObject)
        }
    }
    
    /// Deregisters an object.
    public func deregister(_ object: T) {
        self.logger.debug("\(object.moduleName) has been deregistered.")
        self.serialQueue.async {
            if let weakObject = self.unserializedWeakObjects.first(where: { $0.object == object }) {
                self.unserializedWeakObjects.remove(weakObject)
            }
        }
    }
    
    /// A set of all objects that have registered.
    ///
    /// - Because there is no way to be notified for weak references when they are released, we must first
    /// sanitize the `weakObjects` by removing all the `WeakObject`s where the listener
    /// reference is `nil`.
    ///
    /// - Returns: An array of app state listeners.
    public var objects: Set<T> {
        return self.serialQueue.sync {
            var objectsToDeregister: [WeakObject<T>] = []
            var objectsToReturn: Set<T> = Set()
            for weakObject in self.unserializedWeakObjects {
                if let strongObject = weakObject.object {
                    objectsToReturn.insert(strongObject)
                } else {
                    objectsToDeregister.append(weakObject)
                }
            }

            /// Sanitize the current `WeakObject`s
            for weakObject in objectsToDeregister {
                self.unserializedWeakObjects.remove(weakObject)
            }

            return objectsToReturn
        }
    }
}

// MARK: - WeakListener

/// Structure to hold a weak reference of an object.
private struct WeakObject<T> : Hashable where T: RegisteredObject {

    /// Weak reference to a registered object.
    weak var object: T?

    /// Constructor.
    ///
    /// - Parameter listener: Weak reference to the object listening to app state changes.
    init(object: T) {
        self.object = object
    }

    // Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.object)
    }

    // Equatable
    public static func == (lhs: WeakObject, rhs: WeakObject) -> Bool {
        return lhs.object == rhs.object
    }
}
