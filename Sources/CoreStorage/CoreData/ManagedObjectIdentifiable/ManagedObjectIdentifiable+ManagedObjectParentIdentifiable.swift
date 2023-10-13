//
//  ManagedObjectIdentifiable+ManagedObjectParentIdentifiable.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ManagedObjectParentIdentifiable

public extension ManagedObjectIdentifiable where Self : NSManagedObject, Self : ManagedObjectParentIdentifiable {
    
    static func newFetchedResultsController(
        id: String,
        parentId: String,
        context: NSManagedObjectContext
    ) -> NSFetchedResultsController<Self>{
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        return self.newFetchedResultsController(predicate: predicate, context: context)
    }
    
    static func newFetchedResultsController(
        parentId: String,
        context: NSManagedObjectContext
    ) -> NSFetchedResultsController<Self>{
        let predicate = QueryPredicate.getPredicate(parentId: parentId)
        return self.newFetchedResultsController(predicate: predicate, context: context)
    }
}
