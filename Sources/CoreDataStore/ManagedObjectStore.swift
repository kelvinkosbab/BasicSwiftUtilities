//
//  ManagedObjectStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - ManagedObjectStore

public protocol ManagedObjectStore : ObjectStore where ObjectType : ManagedObjectAssociated, ObjectType.ManagedObject.StructType == ObjectType {
    var context: NSManagedObjectContext { get }
}

public extension ManagedObjectStore {
    
    typealias ManagedObject = ObjectType.ManagedObject
    
    /// Saves any changes on the context.
    ///
    /// If this function throws you should handle the error appropriately. You should NOT use `fatalError()` in a shipping
    /// application, although it may be useful during development.
    func saveContext() {
        
        guard self.context.hasChanges else {
            return
        }
        
        try? self.context.save()
    }
    
    // MARK: - Create or Update
    
    func createOrUpdate(_ object: ObjectType) {
        var cdObject = ManagedObject.fetchOne(id: object.identifier, context: self.context) ?? ManagedObject.create(context: self.context)
        cdObject.structValue = object
        self.saveContext()
    }
    
    // MARK: - Fetching
    
    func fetchOne(id: String) -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return ManagedObject.fetchOne(predicate: predicate, context: self.context)?.structValue
    }
    
    func fetchMany(in ids: [String]) -> [ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        let cdObjects = ManagedObject.fetchMany(predicate: predicate, context: self.context)
        return cdObjects.structValues
    }
    
    func fetchMany(notIn ids: [String]) -> [ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        let cdObjects = ManagedObject.fetchMany(predicate: predicate, context: self.context)
        return cdObjects.structValues
    }
    
    func fetchAll(sortDescriptors: [NSSortDescriptor]?) -> [ManagedObject.StructType] {
        let request = ManagedObject.newFetchRequest(sortDescriptors: sortDescriptors)
        request.returnsObjectsAsFaults = false
        return ManagedObject.fetch(predicate: nil, sortDescriptors: sortDescriptors, context: self.context).structValues
    }
    
    // MARK: - Delete
    
    func delete(_ object: ObjectType) {
        self.deleteOne(id: object.identifier)
        self.saveContext()
    }
    
    func deleteOne(id: String) {
        let predicate = QueryPredicate.getPredicate(id: id)
        ManagedObject.delete(predicate: predicate, context: self.context)
        self.saveContext()
    }
    
    func deleteMany(in ids: [String]) {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        for object in ManagedObject.fetchMany(predicate: predicate, context: self.context) {
            object.delete(context: self.context)
        }
        self.saveContext()
    }
    
    func deleteMany(notIn ids: [String]) {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        for object in ManagedObject.fetchMany(predicate: predicate, context: self.context) {
            object.delete(context: self.context)
        }
        self.saveContext()
    }
    
    func deleteAll() {
        let request = ManagedObject.newFetchRequest(sortDescriptors: nil)
        request.returnsObjectsAsFaults = false
        for object in  ManagedObject.fetch(predicate: nil, sortDescriptors: nil, context: self.context) {
            object.delete(context: self.context)
        }
        self.saveContext()
    }
}

// MARK: - Parent and Child

extension ManagedObjectStore where ObjectType.ManagedObject : ManagedObjectParentIdentifiable {
    
    // MARK: - Fetching
    
    func fetchOne(id: String, parentId: String) -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        return ManagedObject.fetchOne(predicate: predicate, context: self.context)?.structValue
    }

    func fetchMany(in ids: [String], parentId: String) -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        return ManagedObject.fetchMany(predicate: predicate, context: self.context).structValues
    }

    func fetchMany(notIn ids: [String], parentId: String) -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        return ManagedObject.fetchMany(predicate: predicate, context: self.context).structValues
    }
    
    // MARK: - Delete
    
    func deleteOne(id: String, parentId: String) {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        ManagedObject.delete(predicate: predicate, context: self.context)
        self.saveContext()
    }
    
    func deleteMany(in ids: [String], parentId: String) {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        for object in ManagedObject.fetchMany(predicate: predicate, context: self.context) {
            object.delete(context: self.context)
        }
        self.saveContext()
    }
    
    func deleteMany(notIn ids: [String], parentId: String) {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        for object in ManagedObject.fetchMany(predicate: predicate, context: self.context) {
            object.delete(context: self.context)
        }
        self.saveContext()
    }
    
    func deleteMany(parentId: String) {
        let predicate = QueryPredicate.getPredicate(parentId: parentId)
        for object in ManagedObject.fetchMany(predicate: predicate, context: self.context) {
            object.delete(context: self.context)
        }
        self.saveContext()
    }
    
    // MARK: - Data Observers
    
    func createObserver<Delegate: DataObserverDelegate>(id: String, parentId: String) -> DataObserver<Delegate> where Delegate.ObjectType.ManagedObject: ManagedObjectParentIdentifiable {
        return DataObserver(id: id, parentId: parentId, context: self.context)
    }
    
    func createObserver<Delegate: DataObserverDelegate>(parentId: String) -> DataObserver<Delegate> where Delegate.ObjectType.ManagedObject: ManagedObjectParentIdentifiable {
        return DataObserver(parentId: parentId, context: self.context)
    }
}
