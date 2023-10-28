//
//  ObjectStore+ObserverPredicate.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ObserverPredicate

public typealias ObserverPredicate = NSFetchedResultsController

// MARK: - ObjectStore & Fetched Results Controller

@available(iOS 13.0, *)
internal extension ObjectStore {
    
    func newObserverDelete(
        id: String,
        context: NSManagedObjectContext
    ) -> ObserverPredicate<PersistedObject>{
        let predicate = NSPredicate(id: id)
        return self.newObserverDelete(
            predicate: predicate,
            context: context
        )
    }
    
    func newObserverDelete(
        ids: [String],
        context: NSManagedObjectContext
    ) -> ObserverPredicate<PersistedObject>{
        let predicate = NSPredicate(ids: ids)
        return self.newObserverDelete(
            predicate: predicate,
            context: context
        )
    }
    
    func newObserverDelete(
        notIn ids: [String],
        context: NSManagedObjectContext
    ) -> ObserverPredicate<PersistedObject>{
        let predicate = NSPredicate(notIn: ids)
        return self.newObserverDelete(
            predicate: predicate,
            context: context
        )
    }
    
    func newObserverDelete(
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> ObserverPredicate<PersistedObject> {
        let sortDescriptors = sortDescriptors ?? [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let fetchRequest = self.newFetchRequest(
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
