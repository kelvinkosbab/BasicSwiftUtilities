//
//  ObjectStore+FetchedResultsController.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ObjectStore & Fetched Results Controller

@available(iOS 13.0, *)
internal extension ObjectStore {
    
    func newFetchedResultsController(
        id: String,
        context: NSManagedObjectContext
    ) -> NSFetchedResultsController<PersistedObject>{
        let predicate = QueryPredicate.getPredicate(id: id)
        return self.newFetchedResultsController(predicate: predicate, context: context)
    }
    
    func newFetchedResultsController(
        ids: [String],
        context: NSManagedObjectContext
    ) -> NSFetchedResultsController<PersistedObject>{
        let predicate = QueryPredicate.getPredicate(ids: ids)
        return self.newFetchedResultsController(predicate: predicate, context: context)
    }
    
    func newFetchedResultsController(
        notIn ids: [String],
        context: NSManagedObjectContext
    ) -> NSFetchedResultsController<PersistedObject>{
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        return self.newFetchedResultsController(predicate: predicate, context: context)
    }
    
    func newFetchedResultsController(
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> NSFetchedResultsController<PersistedObject> {
        let sortDescriptors = sortDescriptors ?? [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let fetchRequest = self.newFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
