//
//  QueryPredicate.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - NSPredicate

/// A definition of logical conditions for constraining a search for a fetch or for in-memory filtering.
public extension NSPredicate {
    
    /// Query predicate for the given ID.
    ///
    /// - Parameter id: Identifier to query for.
    convenience init(id: String) {
        self.init(
            format: "identifier == %@", 
            id
        )
    }
    
    /// Query predicate for the given IDs.
    ///
    /// - Parameter ids: Identifiers to query for.
    convenience init(ids: [String]) {
        self.init(
            format: "identifier IN %@",
            ids
        )
    }
    
    /// Query predicate for any IDs not included in the set.
    ///
    /// - Parameter ids: Identifiers to exclude from the query.
    convenience init(notIn ids: [String]) {
        self.init(
            format: "NOT (identifier IN %@)",
            ids
        )
    }
    
    /// Query predicate for objects which have the given `parentIdentifier`.
    ///
    /// - Parameter parentId: Parent Identifier of the objects to query for.
    convenience init(parentId: String) {
        self.init(
            format: "parentIdentifier == %@",
            parentId
        )
    }
    
    /// Query predicate for objects which have the given ID and `parentIdentifier`.
    ///
    /// - Parameter id: ID of the object to query for.
    /// - Parameter parentId: Parent Identifier of the object to query for.
    convenience init(id: String, parentId: String) {
        self.init(
            format: "parentIdentifier == %@ && identifier == %@",
            parentId,
            id
        )
    }
    
    /// Query predicate for objects which have the given IDs and `parentIdentifier`.
    ///
    /// - Parameter ids: IDs of the objects to query for.
    /// - Parameter parentId: Parent Identifier of the object to query for.
    convenience init(ids: [String], parentId: String) {
        self.init(
            format: "parentIdentifier == %@ && identifier IN %@",
            parentId,
            ids
        )
    }
    
    /// Query predicate for objects which do not have the given IDs and `parentIdentifier`.
    ///
    /// - Parameter ids: IDs to exclude from the objects to query for.
    /// - Parameter parentId: Parent Identifier of the object to query for.
    convenience init(notIn ids: [String], parentId: String) {
        self.init(
            format: "parentIdentifier == %@ && NOT (identifier IN %@)",
            parentId,
            ids
        )
    }
}
