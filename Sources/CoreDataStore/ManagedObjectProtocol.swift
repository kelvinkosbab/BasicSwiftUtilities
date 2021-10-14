//
//  ManagedObjectProtocol.swift
//
//  Created by Kelvin Kosbab on 10/11/21.
//

import CoreData
import Core

// MARK: - ManagedObjectProtocol

public protocol ManagedObjectProtocol : AnyObject {}

public extension ManagedObjectProtocol where Self : NSManagedObject {
    
    private static var logger: Logger {
        return Logger(subsystem: "CoreDataStore", category: "ManagedObjectProtocol")
    }
    
    private static var entityName: String {
        return String(describing: Self.self)
    }
    
    // MARK: - Create
    
    static func create(context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: context) as! Self
    }
    
    // MARK: - Managed Object Entity
    
    private static func getEntity(context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName, in: context)
    }
    
    // MARK: - Fetching
    
    static func newGenericFetchRequest() throws -> NSFetchRequest<NSFetchRequestResult> {
        
        guard let fetchRequest = NSFetchRequest<Self>(entityName: self.entityName) as? NSFetchRequest<NSFetchRequestResult> else {
            throw ManagedObjectProtocolError.invalidEntity("Unable to generate generic fetch request for entity \(self.entityName)")
        }
        
        return fetchRequest
    }
    
    static func newFetchRequest(sortDescriptors: [NSSortDescriptor]?) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>(entityName: self.entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        return fetchRequest
    }
    
    static func newFetchRequest(predicate: NSPredicate?,
                                sortDescriptors: [NSSortDescriptor]?) -> NSFetchRequest<Self> {
        let fetchRequest = self.newFetchRequest(sortDescriptors: sortDescriptors)
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    static func fetchOne(predicate: NSPredicate, context: NSManagedObjectContext) -> Self? {
        return self.fetch(predicate: predicate, sortDescriptors: nil, context: context).first
    }
    
    static func fetchMany(predicate: NSPredicate,
                          sortDescriptors: [NSSortDescriptor]? = nil,
                          context: NSManagedObjectContext) -> [Self] {
        return self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: context)
    }
    
    static func fetchAll(sortDescriptors: [NSSortDescriptor]?,
                         context: NSManagedObjectContext) -> [Self] {
        let request = self.newFetchRequest(sortDescriptors: sortDescriptors)
        request.returnsObjectsAsFaults = false
        return self.fetch(predicate: nil, sortDescriptors: sortDescriptors, context: context)
    }
    
    private static func fetch(predicate: NSPredicate?,
                              sortDescriptors: [NSSortDescriptor]?,
                              context: NSManagedObjectContext) -> [Self] {
        do {
            let request = self.newFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            request.returnsObjectsAsFaults = false
            return try context.fetch(request)
        } catch {
            self.logger.error("\(self.entityName) : \(predicate.debugDescription) : \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Fetched Results Controller
    
    static func newFetchedResultsController(predicate: NSPredicate?,
                                            sortDescriptors: [NSSortDescriptor],
                                            context: NSManagedObjectContext,
                                            sectionNameKeyPath: String? = nil) -> NSFetchedResultsController<Self> {
        let fetchRequest = self.newFetchRequest(predicate: predicate,
                                                sortDescriptors: sortDescriptors)
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: sectionNameKeyPath,
                                          cacheName: nil)
    }
    
    // MARK: - Fetching Unique
    
    static func fetchManyUnique(properties: [String],
                                predicate: NSPredicate?,
                                sortDescriptors: [NSSortDescriptor]?,
                                context: NSManagedObjectContext) -> [Any] {
        do {
            let request = try self.newGenericFetchRequest()
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            request.resultType = .dictionaryResultType
            request.propertiesToFetch = properties
            request.returnsDistinctResults = true
            
            let result = try context.fetch(request)
            guard let dictionaryArray = result as? [[AnyHashable : Any]] else {
                return []
            }
            
            var uniqueElements: [Any] = []
            for dictionary in dictionaryArray {
                for property in properties {
                    if let value = dictionary[property] {
                        uniqueElements.append(value)
                    }
                }
            }
            return uniqueElements
            
        } catch {
            self.logger.error("\(self.entityName) : \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Deleting
    
    static func deleteOne(predicate: NSPredicate, context: NSManagedObjectContext) {
        if let object = self.fetchOne(predicate: predicate, context: context) {
            self.deleteOne(object)
        }
    }
    
    static func deleteOne(_ object: Self) {
        self.delete(object: object)
    }
    
    static func deleteMany(predicate: NSPredicate, context: NSManagedObjectContext) {
        for object in self.fetchMany(predicate: predicate, context: context) {
            self.delete(object: object)
        }
    }
    
    static func deleteAll(context: NSManagedObjectContext) {
        for object in self.fetchAll(sortDescriptors: nil, context: context) {
            self.delete(object: object)
        }
    }
    
    private static func delete(object: Self) {
        object.managedObjectContext?.delete(object)
    }
    
    // MARK: - Counting
    
    private static func count(predicate: NSPredicate? = nil, context: NSManagedObjectContext) -> Int {
        let request = self.newFetchRequest(predicate: predicate, sortDescriptors: nil)
        request.returnsObjectsAsFaults = false
        request.includesSubentities = false
        do {
            return try context.count(for: request)
        } catch {
            self.logger.error("\(self.entityName) : \(error.localizedDescription)")
            return 0
        }
    }
}

// MARK: - ManagedObjectProtocolError

enum ManagedObjectProtocolError: Error {
    case invalidEntity(String)
}

extension ManagedObjectProtocolError: LocalizedError {
    
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch self {
        case .invalidEntity(let message): return message
        }
    }
}
