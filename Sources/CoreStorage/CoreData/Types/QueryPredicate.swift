//
//  QueryPredicate.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

// MARK: - QueryPredicate

/// Provides built-in predicates for simple queries for `CoreData` and ``ObjectStore``.
public enum Predicate {
    
    /// Query predicate for the given ID.
    ///
    /// - Parameter id: Identifier to query for.
    case id(id: String)
    
    /// Query predicate for the given IDs.
    ///
    /// - Parameter ids: Identifiers to query for.
    case ids(ids: [String])
    
    /// Query predicate for any IDs not included in the set.
    ///
    /// - Parameter ids: Identifiers to exclude from the query.
    case notIn(ids: [String])
    
    /// Query predicate for objects which have the given `parentIdentifier`.
    ///
    /// - Parameter parentId: Parent Identifier of the objects to query for.
    case parentId(_ parentId: String)
    
    /// Query predicate for objects which have the given ID and `parentIdentifier`.
    ///
    /// - Parameter id: ID of the object to query for.
    /// - Parameter parentId: Parent Identifier of the object to query for.
    case id(id: String, parentId: String)
    
    /// Query predicate for objects which have the given IDs and `parentIdentifier`.
    ///
    /// - Parameter ids: IDs of the objects to query for.
    /// - Parameter parentId: Parent Identifier of the object to query for.
    case ids(ids: [String], parentId: String)
    
    /// Query predicate for objects which do not have the given IDs and `parentIdentifier`.
    ///
    /// - Parameter ids: IDs to exclude from the objects to query for.
    /// - Parameter parentId: Parent Identifier of the object to query for.
    case notIn(ids: [String], parentId: String)
    
    internal var predicate: NSPredicate {
        switch self {
        case .id(id: let id):
            NSPredicate(
                format: "identifier == %@",
                id
            )
        case .ids(ids: let ids):
            NSPredicate(
                format: "identifier IN %@",
                ids
            )
        case .notIn(ids: let ids):
            NSPredicate(
                format: "NOT (identifier IN %@)",
                ids
            )
        case .parentId(let parentId):
            NSPredicate(
                format: "parentIdentifier == %@",
                parentId
            )
        case .id(id: let id, parentId: let parentId):
            NSPredicate(
                format: "parentIdentifier == %@ && identifier == %@",
                parentId,
                id
            )
        case .ids(ids: let ids, parentId: let parentId):
            NSPredicate(
                format: "parentIdentifier == %@ && identifier IN %@",
                parentId,
                ids
            )
        case .notIn(ids: let ids, parentId: let parentId):
            NSPredicate(
                format: "parentIdentifier == %@ && NOT (identifier IN %@)",
                parentId,
                ids
            )
        }
    }
    
    static var defaultSortDescriptors = [
        NSSortDescriptor(
            key: "identifier",
            ascending: true
        )
    ]
}
