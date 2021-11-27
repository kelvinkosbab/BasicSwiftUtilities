//
//  CoreDataObserver.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import CoreData
import Core

// MARK: - DataObserver

public protocol DataObserverDelegate : AnyObject {
    
    associatedtype ObjectType : CoreDataAssociated
    
    func didAdd(object: ObjectType.ManagedObject.StructType) -> Void
    func didUpdate(object: ObjectType.ManagedObject.StructType) -> Void
    func didRemove(object: ObjectType.ManagedObject.StructType) -> Void
}

public class DataObserver<Delegate: DataObserverDelegate> : NSObject, NSFetchedResultsControllerDelegate {
    
    
    public typealias ManagedObject = Delegate.ObjectType.ManagedObject
    public typealias ObjectType = ManagedObject.StructType
    
    public weak var delegate: Delegate?
    private let fetchedResultsController: NSFetchedResultsController<ManagedObject>
    private let logger: Logger
    
    public private(set) var objects: Set<ObjectType> = Set()
    
    public convenience init(id: String, context: NSManagedObjectContext) {
        let entityName = String(describing: ManagedObject.self)
        let fetchRequest = NSFetchRequest<ManagedObject>(entityName: entityName)
        fetchRequest.predicate = QueryPredicate.getPredicate(id: id)
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    public convenience init(ids: [String], context: NSManagedObjectContext) {
        let entityName = String(describing: ManagedObject.self)
        let fetchRequest = NSFetchRequest<ManagedObject>(entityName: entityName)
        fetchRequest.predicate = QueryPredicate.getPredicate(ids: ids)
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    public init(fetchedResultsController: NSFetchedResultsController<ManagedObject>) {
        
        self.fetchedResultsController = fetchedResultsController
        self.logger = Logger(subsystem: "CoreDataStore", category: "DatabaseObserver.\(String(describing: ManagedObject.self))")
        
        super.init()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            self.logger.error("Failed to performFetch: \(error.localizedDescription)")
        }
        
        self.fetchedResultsController.delegate = self
        
        for cdObject in self.fetchedResultsController.fetchedObjects ?? [] {
            if let object = cdObject.structValue {
                self.objects.insert(object)
            }
        }
    }
    
    // MARK: - NSFetchedResultsController
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        
        guard let cdObject = anObject as? ManagedObject else {
            self.logger.error("Updated object is not of type NSManagedObject.")
            return
        }
        
        guard let object = cdObject.structValue else {
            return
        }
        
        switch type {
        case .insert:
            
            guard !self.objects.contains(object) else {
                return
            }
            
            self.objects.insert(object)
            self.delegate?.didAdd(object: object)
            
        case .update:
            if self.objects.contains(object) {
                self.objects.update(with: object)
                self.delegate?.didUpdate(object: object)
            } else {
                self.objects.insert(object)
                self.delegate?.didAdd(object: object)
            }
            
        case .delete:
            if self.objects.contains(object) {
                self.objects.remove(object)
                self.delegate?.didRemove(object: object)
            }
            
        case .move:
            self.logger.debug("Unsupported operation 'move'.")
        @unknown default:
            fatalError("Unsupported operation 'unknown' for")
        }
    }
}

public extension DataObserver where Delegate.ObjectType.ManagedObject : CoreDataParentIdentifiable {
    
    convenience init(id: String, parentId: String, context: NSManagedObjectContext) {
        let entityName = String(describing: ManagedObject.self)
        let fetchRequest = NSFetchRequest<ManagedObject>(entityName: entityName)
        fetchRequest.predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    convenience init(parentId: String, context: NSManagedObjectContext) {
        let entityName = String(describing: ManagedObject.self)
        let fetchRequest = NSFetchRequest<ManagedObject>(entityName: entityName)
        fetchRequest.predicate = QueryPredicate.getPredicate(parentId: parentId)
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        self.init(fetchedResultsController: fetchedResultsController)
    }
}
