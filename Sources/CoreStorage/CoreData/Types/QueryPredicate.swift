//
//  QueryPredicate.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - QueryPredicate

/// Provides built-in predicates for simple queries for `CoreData`.
internal struct QueryPredicate {
    
    static var defaultSortDescriptors = [
        NSSortDescriptor(
            key: "identifier",
            ascending: true
        )
    ]
    
    /// Creates a query predicate for the given ID.
    ///
    /// - Parameter id: Identifier to query for.
    static func getPredicate(id: String) -> NSPredicate {
        NSPredicate(
            format: "identifier == %@",
            id
        )
    }
    
    /// Creates a query predicate for the given IDs.
    ///
    /// - Parameter ids: Identifiers to query for.
    static func getPredicate(ids: [String]) -> NSPredicate {
        NSPredicate(
            format: "identifier IN %@",
            ids
        )
    }
    
    /// Creates a query predicate for any IDs not included in the set.
    ///
    /// - Parameter ids: Identifiers to exclude from the query.
    static func getPredicate(notIn ids: [String]) -> NSPredicate {
        NSPredicate(
            format: "NOT (identifier IN %@)",
            ids
        )
    }
    
    /// Creates a query predicate for objects which have the given `parentIdentifier`.
    ///
    /// - Parameter parentId: Parent Identifier of the objects to query for.
    static func getPredicate(parentId: String) -> NSPredicate {
        NSPredicate(
            format: "parentIdentifier == %@",
            parentId
        )
    }
    
    /// Creates a query predicate for objects which have the given ID and `parentIdentifier`.
    ///
    /// - Parameter id: ID of the object to query for.
    /// - Parameter parentId: Parent Identifier of the object to query for.
    static func getPredicate(
        id: String,
        parentId: String
    ) -> NSPredicate {
        NSPredicate(
            format: "parentIdentifier == %@ && identifier == %@",
            parentId,
            id
        )
    }
    
    /// Creates a query predicate for objects which have the given IDs and `parentIdentifier`.
    ///
    /// - Parameter ids: IDs of the objects to query for.
    /// - Parameter parentId: Parent Identifier of the object to query for.
    static func getPredicate(
        ids: [String],
        parentId: String
    ) -> NSPredicate {
        NSPredicate(
            format: "parentIdentifier == %@ && identifier IN %@",
            parentId,
            ids)
    }
    
    /// Creates a query predicate for objects which do not have the given IDs and `parentIdentifier`.
    ///
    /// - Parameter ids: IDs to exclude from the objects to query for.
    /// - Parameter parentId: Parent Identifier of the object to query for.
    static func getPredicate(
        notIn ids: [String],
        parentId: String
    ) -> NSPredicate {
        NSPredicate(
            format: "parentIdentifier == %@ && NOT (identifier IN %@)",
            parentId,
            ids
        )
    }
}
