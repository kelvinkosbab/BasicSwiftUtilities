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
        var cdObject = self.cdFetchOne(id: object.identifier) ?? self.create()
        cdObject.structValue = object
        self.saveContext()
    }
    
    private var entityName: String {
        return String(describing: ObjectType.ManagedObject.self)
    }
    
    private func create() -> ObjectType.ManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: self.context) as! ObjectType.ManagedObject
    }
    
    // MARK: - Fetching
    
    func fetchOne(id: String) -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return self.cdFetchOne(predicate: predicate)?.structValue
    }
    
    func fetchMany(in ids: [String]) -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        let cdObjects = self.cdFetchMany(predicate: predicate)
        return cdObjects.structValues
    }
    
    func fetchMany(notIn ids: [String]) -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        let cdObjects = self.cdFetchMany(predicate: predicate)
        return cdObjects.structValues
    }
    
    func fetchAll(sortDescriptors: [NSSortDescriptor]?) -> [ObjectType.ManagedObject.StructType] {
        let request = self.newFetchRequest(sortDescriptors: sortDescriptors)
        request.returnsObjectsAsFaults = false
        return self.cdFetch(predicate: nil, sortDescriptors: sortDescriptors).structValues
    }
    
    private func cdFetchOne(id: String) -> ObjectType.ManagedObject? {
        let predicate = QueryPredicate.getPredicate(id: id)
        return self.cdFetchOne(predicate: predicate)
    }
    
    private func cdFetchOne(predicate: NSPredicate) -> ObjectType.ManagedObject? {
        return self.cdFetch(predicate: predicate, sortDescriptors: nil).first
    }
    
    private func cdFetchMany(predicate: NSPredicate,
                             sortDescriptors: [NSSortDescriptor]? = nil) -> [ObjectType.ManagedObject] {
        return self.cdFetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }
    
    private func cdFetch(predicate: NSPredicate?,
                         sortDescriptors: [NSSortDescriptor]?) -> [ObjectType.ManagedObject] {
        do {
            let request = self.newFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            request.returnsObjectsAsFaults = false
            return try self.context.fetch(request)
        } catch {
            return []
        }
    }
    
    private func newFetchRequest(predicate: NSPredicate? = nil,
                                 sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<ObjectType.ManagedObject> {
        let fetchRequest = NSFetchRequest<ObjectType.ManagedObject>(entityName: self.entityName)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        return fetchRequest
    }
    
    // MARK: - Delete
    
    func delete(_ object: ObjectType) {
        self.deleteOne(id: object.identifier)
        self.saveContext()
    }
    
    func deleteOne(id: String) {
        let predicate = QueryPredicate.getPredicate(id: id)
        self.cdDelete(predicate: predicate)
        self.saveContext()
    }
    
    func deleteMany(in ids: [String]) {
        let predicate = QueryPredicate.getPredicate(ids: ids)
        let objects = self.cdFetchMany(predicate: predicate)
        for object in objects {
            self.cdDelete(object: object)
        }
        self.saveContext()
    }
    
    func deleteMany(notIn ids: [String]) {
        let predicate = QueryPredicate.getPredicate(notIn: ids)
        let objects = self.cdFetchMany(predicate: predicate)
        for object in objects {
            self.cdDelete(object: object)
        }
        self.saveContext()
    }
    
    func deleteAll() {
        let request = self.newFetchRequest(sortDescriptors: nil)
        request.returnsObjectsAsFaults = false
        for object in  self.cdFetch(predicate: nil, sortDescriptors: nil) {
            self.cdDelete(object: object)
        }
        self.saveContext()
    }
    
    private func cdDelete(predicate: NSPredicate) {
        for object in self.cdFetchMany(predicate: predicate) {
            self.cdDelete(object: object)
        }
    }
    
    private func cdDelete(object: ObjectType.ManagedObject) {
        object.managedObjectContext?.delete(object)
    }
    
    // MARK: - Data Observers
    
    func createObserver<Delegate: DataObserverDelegate>(id: String) -> DataObserver<Delegate> {
        return DataObserver(id: id, context: self.context)
    }
    
    func createObserver<Delegate: DataObserverDelegate>(ids: [String]) -> DataObserver<Delegate> {
        return DataObserver(ids: ids, context: self.context)
    }
}

// MARK: - Parent and Child

extension ManagedObjectStore where ObjectType.ManagedObject : ManagedObjectParentIdentifiable {
    
    // MARK: - Fetching
    
    func fetchOne(id: String, parentId: String) -> ObjectType.ManagedObject.StructType? {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        return self.cdFetchOne(predicate: predicate)?.structValue
    }

    func fetchMany(in ids: [String], parentId: String) -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        return self.cdFetchMany(predicate: predicate).structValues
    }

    func fetchMany(notIn ids: [String], parentId: String) -> [ObjectType.ManagedObject.StructType] {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        return self.cdFetchMany(predicate: predicate).structValues
    }
    
    // MARK: - Delete
    
    func deleteOne(id: String, parentId: String) {
        let predicate = QueryPredicate.getPredicate(id: id, parentId: parentId)
        self.cdDelete(predicate: predicate)
        self.saveContext()
    }
    
    func deleteMany(in ids: [String], parentId: String) {
        let predicate = QueryPredicate.getPredicate(ids: ids, parentId: parentId)
        for object in self.cdFetchMany(predicate: predicate) {
            self.cdDelete(object: object)
        }
        self.saveContext()
    }
    
    func deleteMany(notIn ids: [String], parentId: String) {
        let predicate = QueryPredicate.getPredicate(notIn: ids, parentId: parentId)
        for object in self.cdFetchMany(predicate: predicate) {
            self.cdDelete(object: object)
        }
        self.saveContext()
    }
    
    func deleteMany(parentId: String) {
        let predicate = QueryPredicate.getPredicate(parentId: parentId)
        for object in self.cdFetchMany(predicate: predicate) {
            self.cdDelete(object: object)
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
