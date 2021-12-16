//
//  ManagedObjectIdentifiable+ManagedObject.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

public extension ManagedObjectIdentifiable where Self : NSManagedObject {
    
    static var entityName: String {
        return String(describing: Self.self)
    }
    
    // MARK: - Create
    
    static func create(context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: context) as! Self
    }
    
    // MARK: - Fetch
    
    static func fetchOne(id: String, context: NSManagedObjectContext) -> Self? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return self.fetchOne(predicate: predicate, context: context)
    }
    
    static func fetchOne(predicate: NSPredicate, context: NSManagedObjectContext) -> Self? {
        return self.fetch(predicate: predicate, sortDescriptors: nil, context: context).first
    }
    
    static func fetchMany(predicate: NSPredicate,
                          sortDescriptors: [NSSortDescriptor]? = nil,
                          context: NSManagedObjectContext) -> [Self] {
        return self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: context)
    }
    
    static func fetch(predicate: NSPredicate?,
                      sortDescriptors: [NSSortDescriptor]?,
                      context: NSManagedObjectContext) -> [Self] {
        do {
            let request = self.newFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            request.returnsObjectsAsFaults = false
            return try context.fetch(request)
        } catch {
            return []
        }
    }
    
    static func newFetchRequest(predicate: NSPredicate? = nil,
                                sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>(entityName: self.entityName)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        return fetchRequest
    }
    
    // MARK: - Fetch or Create
    
    static func fetchOrCreate(id: String, context: NSManagedObjectContext) -> Self {
        if let object = self.fetchOne(id: id, context: context) {
            return object
        } else {
            var object = self.create(context: context)
            object.identifier = object.identifier
            return object
        }
    }
    
    // MARK: - Delete
    
    static func delete(predicate: NSPredicate, context: NSManagedObjectContext) {
        for object in self.fetchMany(predicate: predicate, context: context) {
            object.delete(context: context)
        }
    }
    
    func delete(context: NSManagedObjectContext) {
        context.delete(self)
    }
}
