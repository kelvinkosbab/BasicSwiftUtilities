//
//  ObjectStore+ObserverPredicate.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ObjectStore & ObserverPredicate

@available(iOS 13.0, *)
public extension ObjectStore {
    
    // MARK: - Observer of Objects
    
    func newObserver<Delegate>(
        id: String
    ) -> DataObserver<Delegate> where Delegate : DataObserverDelegate, Delegate.Object.PersistentObject == PersistedObject {
        let predicate = NSPredicate(id: id)
        return self.newObserver(
            predicate: predicate
        )
    }
    
    func newObserver<Delegate>(
        ids: [String]
    ) -> DataObserver<Delegate> where Delegate : DataObserverDelegate, Delegate.Object.PersistentObject == PersistedObject {
        let predicate = NSPredicate(ids: ids)
        return self.newObserver(
            predicate: predicate
        )
    }
    
    func newObserver<Delegate>(
        notIn ids: [String]
    ) -> DataObserver<Delegate> where Delegate : DataObserverDelegate, Delegate.Object.PersistentObject == PersistedObject {
        let predicate = NSPredicate(notIn: ids)
        return self.newObserver(
            predicate: predicate
        )
    }
    
    // MARK: - Observer of Objects with Parent
    
    // TODO
    
    // MARK: - Observer by NSPredicate
    
    func newObserver<Delegate>(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> DataObserver<Delegate> where Delegate : DataObserverDelegate, Delegate.Object.PersistentObject == PersistedObject {
        let sortDescriptors = sortDescriptors ?? [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let fetchRequest = self.newFetchRequest( // should make this function it's own protocol extension to share?
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return DataObserver<Delegate>(predicate: controller)
    }
}
