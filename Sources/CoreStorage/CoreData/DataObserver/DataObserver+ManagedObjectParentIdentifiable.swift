//
//  DataObserver+ManagedObjectParentIdentifiable.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - DataObserver & ManagedObjectParentIdentifiable

public extension DataObserver where Delegate.ObjectType.ManagedObject : ManagedObjectParentIdentifiable {
    
    convenience init(
        id: String,
        parentId: String,
        context: NSManagedObjectContext
    ) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(id: id, parentId: parentId, context: context)
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    convenience init(
        parentId: String,
        context: NSManagedObjectContext
    ) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(parentId: parentId, context: context)
        self.init(fetchedResultsController: fetchedResultsController)
    }
}
