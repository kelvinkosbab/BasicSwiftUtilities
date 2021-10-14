//
//  CoreDataObserver.swift
//  
//
//  Created by Kelvin Kosbab on 10/14/21.
//

import Foundation
import CoreData
import Core

// MARK: - CDDatabaseObserver

public protocol CoreDataObserverDelegate : AnyObject {
    
    associatedtype ManagedObject : NSManagedObject & ValueCodable
    
    func didAdd(object: ManagedObject.ValueType) -> Void
    func didUpdate(object: ManagedObject.ValueType) -> Void
    func didRemove(object: ManagedObject.ValueType) -> Void
}

public class CoreDataObserver<Delegate: CoreDataObserverDelegate> : NSObject, NSFetchedResultsControllerDelegate {
    
    public typealias ManagedObject = Delegate.ManagedObject
    
    public weak var delegate: Delegate?
    private let fetchedResultsController: NSFetchedResultsController<ManagedObject>
    private let logger: Logger
    
    public private(set) var object: Delegate.ManagedObject.ValueType?
    
    public init(fetchedResultsController: NSFetchedResultsController<ManagedObject>) {
        self.fetchedResultsController = fetchedResultsController
        self.logger = Logger(subsystem: "CoreDataStore", category: "DatabaseObserver.\(String(describing: ManagedObject.self))")
        super.init()
        
        self.object = self.fetchedResultsController.fetchedObjects?.first?.valueObject
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            self.logger.error("Failed to performFetch from fetchedResultsController: \(error)")
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
        
        guard let object = cdObject.valueObject else {
            return
        }
        
        switch type {
        case .insert:
            self.object = object
            self.delegate?.didAdd(object: object)
            
        case .delete:
            self.object = nil
            self.delegate?.didRemove(object: object)
            
        case .update:
            self.object = object
            self.delegate?.didUpdate(object: object)
            
        case .move:
            self.logger.debug("Unsupported operation 'move'.")
        @unknown default:
            fatalError("Unsupported operation 'unknown' for")
        }
    }
}
