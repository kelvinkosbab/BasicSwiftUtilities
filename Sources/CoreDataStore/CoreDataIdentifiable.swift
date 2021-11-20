//
//  CoreDataIdentifiable.swift
//
//  Created by Kelvin Kosbab on 11/19/21.
//

import CoreData
import Core

// MARK: - CoreDataIdentifiable

public protocol CoreDataIdentifiable {
    var identifier: String? { get set }
}

public extension CoreDataObject where Self : NSManagedObject & CoreDataIdentifiable {
    
    // MARK: - Query Strings
    
    private static var identifierEquals: String {
        return "identifier == %@"
    }
    
    private static var identifierIn: String {
        return "identifier IN %@"
    }
    
    private static var identifierNotIn: String {
        return "NOT (identifier IN %@)"
    }
    
    // MARK: - Fetching by ID
    
    static func fetchOne(id: String, context: NSManagedObjectContext) -> Self? {
        let predicate = NSPredicate(format: self.identifierEquals, id)
        return self.fetchOne(predicate: predicate, context: context)
    }
    
    static func fetchOneOrCreate(id: String, context: NSManagedObjectContext) -> Self {
        if let object = self.fetchOne(id: id, context: context) {
            return object
        } else {
            var object = self.create(context: context)
            object.identifier = id
            return object
        }
    }
    
    static func fetchMany(in ids: [String], context: NSManagedObjectContext) -> [Self] {
        let predicate = NSPredicate(format: self.identifierIn, ids)
        return self.fetchMany(predicate: predicate, context: context)
    }
    
    static func fetchMany(notIn ids: [String], context: NSManagedObjectContext) -> [Self] {
        let predicate = NSPredicate(format: self.identifierNotIn, ids)
        return self.fetchMany(predicate: predicate, context: context)
    }
    
    // MARK: - Delete by ID
    
    static func deleteOne(id: String, context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: self.identifierEquals, id)
        self.deleteOne(predicate: predicate, context: context)
    }
    
    @discardableResult
    static func deleteMany(in ids: [String], context: NSManagedObjectContext) -> Set<String> {
        let predicate = NSPredicate(format: self.identifierIn, ids)
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
    static func deleteMany(notIn ids: [String], context: NSManagedObjectContext) -> Set<String> {
        let predicate = NSPredicate(format: self.identifierNotIn, ids)
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
    
    // MARK: - NSFetchedResultsController by ID
    
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [ NSSortDescriptor(key: "identifier", ascending: true) ]
    }
    
    static func newFetchedResultsController(id: String,
                                            context: NSManagedObjectContext,
                                            sortDescriptors: [NSSortDescriptor] = Self.defaultSortDescriptors) -> NSFetchedResultsController<Self> {
        let predicate = NSPredicate(format: self.identifierEquals, id)
        return self.newFetchedResultsController(predicate: predicate,
                                                sortDescriptors: sortDescriptors,
                                                context: context)
    }
    
    static func newFetchedResultsController(ids: [String],
                                            context: NSManagedObjectContext,
                                            sortDescriptors: [NSSortDescriptor] = Self.defaultSortDescriptors) -> NSFetchedResultsController<Self> {
        let predicate = NSPredicate(format: self.identifierIn, ids)
        return self.newFetchedResultsController(predicate: predicate,
                                                sortDescriptors: sortDescriptors,
                                                context: context)
    }
}
