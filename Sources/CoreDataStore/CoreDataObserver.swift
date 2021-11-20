//
//  CoreDataObserver.swift
//
//  Created by Kelvin Kosbab on 10/14/21.
//

import Foundation
import CoreData
import Core

// MARK: - CoreDataObserver

public protocol CoreDataObserverDelegate : AnyObject {
    
    associatedtype StructType : CoreDataAssociated
    
    func didAdd(object: StructType.ManagedObject.StructType) -> Void
    func didUpdate(object: StructType.ManagedObject.StructType) -> Void
    func didRemove(object: StructType.ManagedObject.StructType) -> Void
}

public class CoreDataObserver<Delegate: CoreDataObserverDelegate> : NSObject, NSFetchedResultsControllerDelegate {
    
    public typealias ManagedObject = Delegate.StructType.ManagedObject
    public typealias StructType = ManagedObject.StructType
    
    public weak var delegate: Delegate?
    private let fetchedResultsController: NSFetchedResultsController<ManagedObject>
    private let logger: Logger
    
    public private(set) var objects: Set<StructType> = Set()
    
    public convenience init(id: String, context: NSManagedObjectContext) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(id: id, context: context)
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    public convenience init(id: String, parentId: String, context: NSManagedObjectContext) {
        let sortDescriptors = [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let predicate = NSPredicate(format: "identifier == %@ AND parentIdentifier == %@", id, parentId)
        let fetchedResultsController = ManagedObject.newFetchedResultsController(predicate: predicate,
                                                                                 sortDescriptors: sortDescriptors,
                                                                                 context: context)
        self.init(fetchedResultsController: fetchedResultsController)
    }
    
    public convenience init(childrenOfParentId parentId: String, context: NSManagedObjectContext) {
        let sortDescriptors = [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let predicate = NSPredicate(format: "parentIdentifier == %@", parentId)
        let fetchedResultsController = ManagedObject.newFetchedResultsController(predicate: predicate,
                                                                                 sortDescriptors: sortDescriptors,
                                                                                 context: context)
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
