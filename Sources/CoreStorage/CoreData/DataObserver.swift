//
//  CoreDataObserver.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import CoreData
import Core

// MARK: - DataObserverDelegate

/// Deflines the interface for objects to listen to underlyhing data store udpates for a given data type.
public protocol DataObserverDelegate : AnyObject where ObjectType == ObjectType.ManagedObject.StructType {
    
    /// Object which is associated with a `CoreData` manged object.
    associatedtype ObjectType : ManagedObjectAssociated
    
    /// Called when an object is added to the data store.
    ///
    /// - Parameter object: Object which was added to the data store.
    func didAdd(object: ObjectType) -> Void
    
    /// Called when an object is updated in the data store.
    ///
    /// - Parameter object: Object which was updated in the data store.
    func didUpdate(object: ObjectType) -> Void
    
    /// Called when an object is removed from the data store.
    ///
    /// - Parameter object: Object which was removed from the data store.
    func didRemove(object: ObjectType) -> Void
}

// MARK: - DataObserver

/// Provides a way for a module to actively listen to underlying `CoreData` object changes.
///
/// - Note: This is a `class` object to convorm to `CoreData.NSFetchedResultsControllerDelegate`
///
/// Example usage for an object that listens to updates for a user profile object:
/// ```swift
/// public protocol UserProfileObserverDelegate : AnyObject {
///     func didAdd(userProfile: UserProfile)
///     func didUpdate(userProfile: UserProfile)
///     func didRemove(userProfile: UserProfile)
/// }
///
/// public class UserProfileObserver : Hashable, DataObserverDelegate {
///
///     public weak var delegate: UserProfileObserverDelegate?
///     private let id: String
///     private let observer: DataObserver<UserProfileObserver>
///
///     public var userProfiles: Set<UserProfile> {
///         return self.observer.objects
///     }
///
///     public convenience init(id: String) {
///         let observer: DataObserver<UserProfileObserver> = DataObserver(
///             id: id,
///             context: TallyBokDataContainer.shared.context
///         )
///         self.init(hashValue: id, observer: observer)
///     }
///
///     internal init(
///         hashValue: String,
///         observer: DataObserver<UserProfileObserver>
///     ) {
///         self.id = "UserProfile.\(hashValue)"
///         self.observer = observer
///         observer.delegate = self
///     }
///
///     public func hash(into hasher: inout Hasher) {
///         hasher.combine(self.id)
///     }
///
///     public static func ==(lhs: UserProfileObserver, rhs: UserProfileObserver) -> Bool {
///         return lhs.id == rhs.id
///     }
///
///     // MARK: - DataObserverDelegate
///
///     public func didAdd(object: UserProfile) {
///         self.delegate?.didAdd(userProfile: object)
///     }
///
///     public func didUpdate(object: UserProfile) {
///         self.delegate?.didAdd(userProfile: object)
///     }
///
///     public func didRemove(object: UserProfile) {
///         self.delegate?.didAdd(userProfile: object)
///     }
/// }
/// ```
public class DataObserver<Delegate: DataObserverDelegate> : NSObject, NSFetchedResultsControllerDelegate {
    
    public typealias ManagedObject = Delegate.ObjectType.ManagedObject
    public typealias ObjectType = Delegate.ObjectType
    
    public weak var delegate: Delegate?
    private let fetchedResultsController: NSFetchedResultsController<ManagedObject>
    private let logger: Loggable
    
    public private(set) var objects: Set<ObjectType> = Set()
    
    public convenience init(
        context: NSManagedObjectContext,
        delegate: Delegate? = nil
    ) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(context: context)
        self.init(
            fetchedResultsController: fetchedResultsController,
            delegate: delegate
        )
    }
    
    public convenience init(
        id: String,
        context: NSManagedObjectContext,
        delegate: Delegate? = nil
    ) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(id: id, context: context)
        self.init(
            fetchedResultsController: fetchedResultsController,
            delegate: delegate
        )
    }
    
    public convenience init(
        ids: [String],
        context: NSManagedObjectContext,
        delegate: Delegate? = nil
    ) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(ids: ids, context: context)
        self.init(
            fetchedResultsController: fetchedResultsController,
            delegate: delegate
        )
    }
    
    public init(
        fetchedResultsController: NSFetchedResultsController<ManagedObject>,
        delegate: Delegate? = nil
    ) {
        self.delegate = delegate
        self.fetchedResultsController = fetchedResultsController
        self.logger = SubsystemCategoryLogger(
            subsystem: "CoreDataStore",
            category: "DatabaseObserver.\(String(describing: ManagedObject.self))"
        )
        
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
    
    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        
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
            fatalError("Unsupported operation 'unknown' for DataObserver")
        }
    }
}

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
    
    convenience init(parentId: String, context: NSManagedObjectContext) {
        let fetchedResultsController = ManagedObject.newFetchedResultsController(parentId: parentId, context: context)
        self.init(fetchedResultsController: fetchedResultsController)
    }
}
