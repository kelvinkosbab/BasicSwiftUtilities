//
//  DataObserver.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData
import Core

// MARK: - DataObserver

/// Provides a way for a module to actively listen to underlying `CoreData` object changes.
///
/// - Note: This is a `class` object to conform to `CoreData.NSFetchedResultsControllerDelegate`
///
/// Example usage for an object that listens to updates for a user profile object:
/// ```swift
/// public protocol UserProfileObserverDelegate : AnyObject {
///     func didAdd(userProfile: UserProfile)
///     func didUpdate(userProfile: UserProfile)
///     func didRemove(userProfile: UserProfile)
/// }
///
/// public class UserProfileObserver : DataObserverDelegate {
///
///     public weak var delegate: UserProfileObserverDelegate?
///     private let id: String
///     private let observer: DataObserver<UserProfileObserver>
///
///     public var userProfiles: Set<UserProfile> {
///         return self.observer.objects
///     }
///
///     public convenience init(id: String) {
///         let observer: DataObserver<UserProfileObserver> = DataObserver(
///             id: id,
///             context: TallyBokDataContainer.shared.context
///         )
///         self.init(hashValue: id, observer: observer)
///     }
///
///     internal init(
///         hashValue: String,
///         observer: DataObserver<UserProfileObserver>
///     ) {
///         self.id = "UserProfile.\(hashValue)"
///         self.observer = observer
///         observer.delegate = self
///     }
///
///     // MARK: - DataObserverDelegate
///
///     public func didAdd(object: UserProfile) {
///         self.delegate?.didAdd(userProfile: object)
///     }
///
///     public func didUpdate(object: UserProfile) {
///         self.delegate?.didAdd(userProfile: object)
///     }
///
///     public func didRemove(object: UserProfile) {
///         self.delegate?.didAdd(userProfile: object)
///     }
/// }
/// ```
public class DataObserver<Delegate>: NSObject, NSFetchedResultsControllerDelegate where Delegate: DataObserverDelegate {

    public typealias PersistedObject = Delegate.Object.PersistentObject
    public typealias Object = Delegate.Object

    public weak var delegate: Delegate?
    private let predicate: NSFetchedResultsController<PersistedObject>
    private let logger: Loggable

    public private(set) var objects: Set<Object> = Set()

    public init(
        predicate: NSFetchedResultsController<PersistedObject>
    ) {
        self.predicate = predicate
        self.logger = Logger(
            subsystem: "DataObserver",
            category: String(describing: PersistedObject.self)
        )

        super.init()

        do {
            try self.predicate.performFetch()
        } catch {
            self.logger.error("Failed to performFetch: \(error.localizedDescription)")
        }

        self.predicate.delegate = self

        for cdObject in self.predicate.fetchedObjects ?? [] {
            if let object = cdObject.structValue {
                self.objects.insert(object)
            } else {
                self.logger.error("Unable to cast fetched object to associated type")
            }
        }
    }

    // MARK: - NSFetchedResultsController

    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {

        guard let cdObject = anObject as? PersistedObject else {
            self.logger.error("Updated object is not castable to `PersistedObject`")
            return
        }

        guard let object = cdObject.structValue else {
            self.logger.error("Unable to cast persistent object to the associated type")
            return
        }

        switch type {
        case .insert:
            self.objects.insert(object)
            self.delegate?.didAdd(object: object)

        case .update:
            self.objects.remove(object)
            self.objects.insert(object)
            self.delegate?.didUpdate(object: object)

        case .delete:
            if self.objects.contains(object) {
                self.objects.remove(object)
                self.delegate?.didRemove(object: object)
            }

        case .move:
            self.logger.error("Unsupported operation 'move'")

        @unknown default:
            self.logger.error("Unsupported operation 'unknown' for DataObserver")
            fatalError("Unsupported operation 'unknown' for DataObserver")
        }
    }
}
