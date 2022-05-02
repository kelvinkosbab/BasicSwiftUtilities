//
//  ManagedObjectIdentifiable+ManagedObject.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ManagedObjectIdentifiable

public extension ManagedObjectIdentifiable where Self : NSManagedObject {
    
    static var entityName: String {
        return String(describing: Self.self)
    }
    
    // MARK: - Create
    
    static func create(context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: context) as! Self
    }
    
    // MARK: - Fetch
    
    static func fetchOne(
        id: String,
        context: NSManagedObjectContext
    ) -> Self? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return self.fetchOne(predicate: predicate, context: context)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    static func fetchOne(
        id: String,
        context: NSManagedObjectContext
    ) async -> Self? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return await self.fetchOne(predicate: predicate, context: context)
    }
    
    static func fetchOne(
        predicate: NSPredicate,
        context: NSManagedObjectContext
    ) -> Self? {
        return self.fetch(predicate: predicate, sortDescriptors: nil, context: context).first
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    static func fetchOne(
        predicate: NSPredicate,
        context: NSManagedObjectContext
    ) async -> Self? {
        return await context.perform {
            let request = self.newFetchRequest(predicate: predicate)
            return try? context.fetch(request).first
        }
    }
    
    static func fetch(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil,
        context: NSManagedObjectContext
    ) -> [Self] {
        let request = self.newFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
        let fetched = try? context.fetch(request)
        return fetched ?? []
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    static func fetch(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil,
        context: NSManagedObjectContext
    ) async -> [Self] {
        return await context.perform {
            let request = self.newFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
            let fetched = try? context.fetch(request)
            return fetched ?? []
        }
    }
    
    static func newFetchRequest(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>(entityName: self.entityName)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        fetchRequest.returnsObjectsAsFaults = false
        return fetchRequest
    }
    
    // MARK: - Fetch or Create
    
    static func fetchOrCreate(
        id: String,
        context: NSManagedObjectContext
    ) -> Self {
        if let object = self.fetchOne(id: id, context: context) {
            return object
        } else {
            var object = self.create(context: context)
            object.identifier = object.identifier
            return object
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    static func fetchOrCreate(
        id: String,
        context: NSManagedObjectContext
    ) async -> Self {
        return await context.perform {
            let predicate = QueryPredicate.getPredicate(id: id)
            let request = self.newFetchRequest(predicate: predicate)
            let fetched = try? context.fetch(request).first
            return fetched ?? self.create(context: context)
        }
    }
    
    // MARK: - Delete
    
    static func delete(
        predicate: NSPredicate?,
        context: NSManagedObjectContext
    ) {
        for object in self.fetch(predicate: predicate, context: context) {
            object.delete(context: context)
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    static func delete(
        predicate: NSPredicate?,
        context: NSManagedObjectContext
    ) async {
        return await context.perform {
            let request = self.newFetchRequest(predicate: predicate)
            let fetched = try? context.fetch(request)
            for object in fetched ?? [] {
                context.delete(object)
            }
        }
    }
    
    func delete(context: NSManagedObjectContext) {
        context.delete(self)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func delete(context: NSManagedObjectContext) async {
        await context.perform { [weak self, weak context] in
            if let self = self {
                context?.delete(self)
            }
        }
    }
    
    // MARK: - Fetched Results Controller
    
    static func newFetchedResultsController(
        id: String,
        context: NSManagedObjectContext
    ) -> NSFetchedResultsController<Self>{
        let predicate = QueryPredicate.getPredicate(id: id)
        return self.newFetchedResultsController(predicate: predicate, context: context)
    }
    
    static func newFetchedResultsController(
        ids: [String],
        context: NSManagedObjectContext
    ) -> NSFetchedResultsController<Self>{
        let predicate = QueryPredicate.getPredicate(ids: ids)
        return self.newFetchedResultsController(predicate: predicate, context: context)
    }
    
    static func newFetchedResultsController(
        notIn ids: [String],
        context: NSManagedObjectContext
    ) -> NSFetchedResultsController<Self>{
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        return self.newFetchedResultsController(predicate: predicate, context: context)
    }
    
    static func newFetchedResultsController(
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> NSFetchedResultsController<Self> {
        let sortDescriptors = sortDescriptors ?? [ NSSortDescriptor(key: "identifier", ascending: true) ]
        let fetchRequest = self.newFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
}

// MARK: - ManagedObjectParentIdentifiable

public extension ManagedObjectIdentifiable where Self : NSManagedObject, Self : ManagedObjectParentIdentifiable {
    
    static func newFetchedResultsController(
        id: String,
        parentId: String,
        context: NSManagedObjectContext
    ) -> NSFetchedResultsController<Self>{
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        return self.newFetchedResultsController(predicate: predicate, context: context)
    }
    
    static func newFetchedResultsController(
        parentId: String,
        context: NSManagedObjectContext
    ) -> NSFetchedResultsController<Self>{
        let predicate = QueryPredicate.getPredicate(parentId: parentId)
        return self.newFetchedResultsController(predicate: predicate, context: context)
    }
}
