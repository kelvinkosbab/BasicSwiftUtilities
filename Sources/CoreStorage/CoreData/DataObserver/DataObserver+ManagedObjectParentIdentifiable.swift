//
//  DataObserver+PersistedObjectParentIdentifiable.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - DataObserver & PersistedObjectParentIdentifiable

public extension DataObserver where Delegate.ObjectType.PersistentObject : PersistedObjectParentIdentifiable {
    
    convenience init(
        id: String,
        parentId: String,
        context: NSManagedObjectContext
    ) {
        let fetchedResultsController = PersistedObject.newFetchedResultsController(
            id: id,
            parentId: parentId,
            context: context
        )
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    convenience init(
        parentId: String,
        context: NSManagedObjectContext
    ) {
        let fetchedResultsController = PersistedObject.newFetchedResultsController(
            parentId: parentId,
            context: context
        )
        self.init(fetchedResultsController: fetchedResultsController)
    }
}
