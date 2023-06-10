//
//  QueryPredicate.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import CoreData

// MARK: - QueryPredicate

internal struct QueryPredicate {
    static var defaultSortDescriptors = [ NSSortDescriptor(key: "identifier", ascending: true) ]
    
    static func getPredicate(id: String) -> NSPredicate {
        return NSPredicate(format: "identifier == %@", id)
    }
    
    static func getPredicate(ids: [String]) -> NSPredicate {
        return NSPredicate(format: "identifier IN %@", ids)
    }
    
    static func getPredicate(notIn ids: [String]) -> NSPredicate {
        return NSPredicate(format: "NOT (identifier IN %@)", ids)
    }
    
    static func getPredicate(parentId: String) -> NSPredicate {
        return NSPredicate(format: "parentIdentifier == %@", parentId)
    }
    
    static func getPredicate(id: String, parentId: String) -> NSPredicate {
        return NSPredicate(format: "parentIdentifier == %@ && identifier == %@", parentId, id)
    }
    
    static func getPredicate(ids: [String], parentId: String) -> NSPredicate {
        return NSPredicate(format: "parentIdentifier == %@ && identifier IN %@", parentId, ids)
    }
    
    static func getPredicate(notIn ids: [String], parentId: String) -> NSPredicate {
        return NSPredicate(format: "parentIdentifier == %@ && NOT (identifier IN %@)", parentId, ids)
    }
}
