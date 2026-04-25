//
//  ObjectStore+ObserverPredicate.swift
//
//  Copyright © Kozinga. All rights reserved.
//

public import CoreData

// MARK: - ObjectStore & ObserverPredicate

public extension ObjectStore {

    // MARK: - Observer of Objects

    /// Creates a ``DataObserver`` for objects matching the given identifier.
    ///
    /// - Parameter id: The unique identifier to observe.
    /// - Returns: A new ``DataObserver`` configured to observe matching objects.
    /// - Throws: An `NSError` from CoreData if the initial fetch fails.
    func newObserver<Delegate>(
        id: String
    ) throws -> DataObserver<Delegate> where Delegate: DataObserverDelegate,
                                             Delegate.Object.PersistentObject == PersistedObject {
        let predicate = NSPredicate(id: id)
        return try self.newObserver(
            predicate: predicate
        )
    }

    /// Creates a ``DataObserver`` for objects whose identifier appears in the given list.
    ///
    /// - Parameter ids: The identifiers to observe.
    /// - Returns: A new ``DataObserver`` configured to observe matching objects.
    /// - Throws: An `NSError` from CoreData if the initial fetch fails.
    func newObserver<Delegate>(
        ids: [String]
    ) throws -> DataObserver<Delegate> where Delegate: DataObserverDelegate,
                                             Delegate.Object.PersistentObject == PersistedObject {
        let predicate = NSPredicate(ids: ids)
        return try self.newObserver(
            predicate: predicate
        )
    }

    /// Creates a ``DataObserver`` for objects whose identifier does NOT appear in the given list.
    ///
    /// - Parameter ids: The identifiers to exclude from observation.
    /// - Returns: A new ``DataObserver`` configured to observe matching objects.
    /// - Throws: An `NSError` from CoreData if the initial fetch fails.
    func newObserver<Delegate>(
        notIn ids: [String]
    ) throws -> DataObserver<Delegate> where Delegate: DataObserverDelegate,
                                             Delegate.Object.PersistentObject == PersistedObject {
        let predicate = NSPredicate(notIn: ids)
        return try self.newObserver(
            predicate: predicate
        )
    }

    // MARK: - Observer by NSPredicate

    /// Creates a ``DataObserver`` for objects matching the given predicate and sort order.
    ///
    /// - Parameter predicate: An optional `NSPredicate` to filter observed objects.
    /// - Parameter sortDescriptors: Optional sort descriptors. Defaults to ascending by `identifier`.
    /// - Returns: A new ``DataObserver`` configured to observe matching objects.
    /// - Throws: An `NSError` from CoreData if the initial fetch fails.
    func newObserver<Delegate>(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> DataObserver<Delegate> where Delegate: DataObserverDelegate,
                                             Delegate.Object.PersistentObject == PersistedObject {
        let sortDescriptors = sortDescriptors ?? [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let fetchRequest = self.newFetchRequest(
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return try DataObserver<Delegate>(predicate: controller)
    }
}
