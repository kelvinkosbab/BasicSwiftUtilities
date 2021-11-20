//
//  CoreDataIdentifiableParent.swift
//
//  Created by Kelvin Kosbab on 11/19/21.
//

import CoreData
import Core

// MARK: - CoreDataIdentifiableParent

public protocol CoreDataIdentifiableParent {
    var parentIdentifier: String? { get set }
}

public extension CoreDataObject where Self : NSManagedObject & CoreDataIdentifiable & CoreDataIdentifiableParent {
    
    // MARK: - Query Strings
    
    private static var parentEquals: String {
        return "parentIdentifier == %@"
    }
    
    private static var parentEqualsANDidentifierEquals: String {
        return "parentIdentifier == %@ && identifier == %@"
    }
    
    private static var parentEqualsANDidentifierIn: String {
        return "parentIdentifier == %@ && identifier IN %@"
    }
    
    private static var parentEqualsANDidentifierNotIn: String {
        return "parentIdentifier == %@ && NOT (identifier IN %@)"
    }
    
    // MARK: - Fetching
    
    static func fetchOne(id: String, parent: String, context: NSManagedObjectContext) -> Self? {
        let predicate = NSPredicate(format: self.parentEqualsANDidentifierEquals, parent, id)
        return self.fetchOne(predicate: predicate, context: context)
    }
    
    static func fetchOneOrCreate(id: String, parent: String, context: NSManagedObjectContext) -> Self {
        if let object = self.fetchOne(id: id, parent: parent, context: context) {
            return object
        } else {
            var object = self.create(context: context)
            object.identifier = id
            object.parentIdentifier = parent
            return object
        }
    }
    
    static func fetchMany(in ids: [String], parent: String, context: NSManagedObjectContext) -> [Self] {
        let predicate = NSPredicate(format: self.parentEqualsANDidentifierIn, parent, ids)
        return self.fetchMany(predicate: predicate, context: context)
    }
    
    static func fetchMany(notIn ids: [String], parent: String, context: NSManagedObjectContext) -> [Self] {
        let predicate = NSPredicate(format: self.parentEqualsANDidentifierNotIn, parent, ids)
        return self.fetchMany(predicate: predicate, context: context)
    }
    
    // MARK: - Delete
    
    static func deleteOne(id: String, parent: String, context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: self.parentEqualsANDidentifierEquals, parent, id)
        self.deleteOne(predicate: predicate, context: context)
    }
    
    @discardableResult
    static func deleteMany(in ids: [String], parent: String, context: NSManagedObjectContext) -> Set<String> {
        let predicate = NSPredicate(format: self.parentEqualsANDidentifierIn, parent, ids)
        let objects = self.fetchMany(predicate: predicate, context: context)
        var deletedIds: Set<String> = Set()
        for object in objects {
            if let identifier = object.identifier {
                deletedIds.insert(identifier)
            }
            self.deleteOne(object)
        }
        return deletedIds
    }
    
    @discardableResult
    static func deleteMany(notIn ids: [String], parent: String, context: NSManagedObjectContext) -> Set<String> {
        let predicate = NSPredicate(format: self.parentEqualsANDidentifierNotIn, parent, ids)
        let objects = self.fetchMany(predicate: predicate, context: context)
        var deletedIds: Set<String> = Set()
        for object in objects {
            if let identifier = object.identifier {
                deletedIds.insert(identifier)
            }
            self.deleteOne(object)
        }
        return deletedIds
    }
    
    @discardableResult
    static func deleteMany(parent: String, context: NSManagedObjectContext) -> Set<String> {
        let predicate = NSPredicate(format: self.parentEquals, parent)
        let objects = self.fetchMany(predicate: predicate, context: context)
        var deletedIds: Set<String> = Set()
        for object in objects {
            if let identifier = object.identifier {
                deletedIds.insert(identifier)
            }
            self.deleteOne(object)
        }
        return deletedIds
    }
    
    // MARK: - NSFetchedResultsController
    
    static func newFetchedResultsController(parent: String,
                                            context: NSManagedObjectContext,
                                            sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchedResultsController<Self> {
        let predicate = NSPredicate(format: self.parentEquals, parent)
        let sortDescriptors = sortDescriptors ?? self.defaultSortDescriptors
        return self.newFetchedResultsController(predicate: predicate, sortDescriptors: sortDescriptors, context: context)
    }
    
    static func newFetchedResultsController(id: String,
                                            parent: String,
                                            context: NSManagedObjectContext,
                                            sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchedResultsController<Self> {
        let predicate = NSPredicate(format: self.parentEqualsANDidentifierEquals, parent, id)
        let sortDescriptors = sortDescriptors ?? self.defaultSortDescriptors
        return self.newFetchedResultsController(predicate: predicate, sortDescriptors: sortDescriptors, context: context)
    }
    
    static func newFetchedResultsController(ids: [String],
                                            parent: String,
                                            context: NSManagedObjectContext,
                                            sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchedResultsController<Self> {
        let predicate = NSPredicate(format: self.parentEqualsANDidentifierIn, parent, ids)
        let sortDescriptors = sortDescriptors ?? self.defaultSortDescriptors
        return self.newFetchedResultsController(predicate: predicate, sortDescriptors: sortDescriptors, context: context)
    }
}
