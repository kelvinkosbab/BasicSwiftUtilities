//
//  QueryPredicate.swift
//  
//  Created by Kelvin Kosbab on 11/25/21.
//

import Foundation
import CoreData

// MARK: - QueryPredicate

internal struct QueryPredicate {
    static var defaultSortDescriptors = [ NSSortDescriptor(key: "identifier", ascending: true) ]
    
    static func getPredicate(id: String) -> NSPredicate {
        return NSPredicate(format: "identifier == %@", id)
    }
    
    static func getPredicate(ids: [String]) -> NSPredicate {
        return NSPredicate(format: "identifier IN %@", ids)
    }
    
    static func getPredicate(notIn ids: [String]) -> NSPredicate {
        return NSPredicate(format: "NOT (identifier IN %@)", ids)
    }
    
    static func getPredicate(parentId: String) -> NSPredicate {
        return NSPredicate(format: "parentIdentifier == %@", parentId)
    }
    
    static func getPredicate(id: String, parentId: String) -> NSPredicate {
        return NSPredicate(format: "parentIdentifier == %@ && identifier == %@", parentId, id)
    }
    
    static func getPredicate(ids: [String], parentId: String) -> NSPredicate {
        return NSPredicate(format: "parentIdentifier == %@ && identifier IN %@", parentId, ids)
    }
    
    static func getPredicate(notIn ids: [String], parentId: String) -> NSPredicate {
        return NSPredicate(format: "parentIdentifier == %@ && NOT (identifier IN %@)", parentId, ids)
    }
    
    // TODO
//    static func newFetchedResultsController<T>(id: String, context: NSManagedObjectContext) -> NSFetchedResultsController<T>{
//        let predicate =
//        return self.newFetchedResultsController(predicate: predicate, context: context)
//
//    }
//
//    static func newFetchedResultsController<T>(ids: [String],
//                                               context: NSManagedObjectContext,
//                                               sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchedResultsController<T> {
//        let predicate = NSPredicate(format: self.identifierIn, ids)
//        return self.newFetchedResultsController(predicate: predicate,
//                                                context: context,
//                                                sortDescriptors: sortDescriptors)
//    }
//
//    private static func newFetchedResultsController<T>(predicate: NSPredicate?,
//                                                       context: NSManagedObjectContext,
//                                                       sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchedResultsController<T> {
//        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
//        fetchRequest.predicate = predicate
//        fetchRequest.sortDescriptors = sortDescriptors ?? self.defaultSortDescriptors
//        return NSFetchedResultsController(fetchRequest: fetchRequest,
//                                          managedObjectContext: context,
//                                          sectionNameKeyPath: nil,
//                                          cacheName: nil)
//    }
    
//    public convenience init(id: String, parentId: String, context: NSManagedObjectContext) {
//        let sortDescriptors = [ NSSortDescriptor(key: "identifier", ascending: true) ]
//        let predicate = NSPredicate(format: "identifier == %@ AND parentIdentifier == %@", id, parentId)
//        let fetchedResultsController = ManagedObject.newFetchedResultsController(predicate: predicate,
//                                                                                 sortDescriptors: sortDescriptors,
//                                                                                 context: context)
//        self.init(fetchedResultsController: fetchedResultsController)
//    }
//
//    public convenience init(childrenOfParentId parentId: String, context: NSManagedObjectContext) {
//        let sortDescriptors = [ NSSortDescriptor(key: "identifier", ascending: true) ]
//        let predicate = NSPredicate(format: "parentIdentifier == %@", parentId)
//        let fetchedResultsController = ManagedObject.newFetchedResultsController(predicate: predicate,
//                                                                                 sortDescriptors: sortDescriptors,
//                                                                                 context: context)
//        self.init(fetchedResultsController: fetchedResultsController)
//    }
}
