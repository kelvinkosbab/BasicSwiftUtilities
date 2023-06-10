//
//  QueryExecutor.swift
//
//  Created by Kelvin Kosbab on 4/16/22.
//

import HealthKit

// MARK: - QueryExecutor

/// Defines objects that can execute HealthKit queries.
@available(macOS 13.0, *)
public protocol QueryExecutor {
    
    /// Begins executing the given query.
    ///
    /// After executing a query, the completion, update, and/or results handlers of that query will be invoked
    /// asynchronously on an arbitrary background queue as results become available.  Errors that prevent a
    /// query from executing will be delivered to one of the query's handlers.  Which handler the error will be
    /// delivered to is defined by the HKQuery subclass.
    ///
    /// Each HKQuery instance may only be executed once and calling this method with a currently executing query
    /// or one that was previously executed will result in an exception.
    ///
    /// If a query would retrieve objects with an HKObjectType property, then the application must request
    /// authorization to access objects of that type before executing the query.
    func execute(_ query: HKQuery)
}

// MARK: - HKHealthStore

@available(macOS 13.0, *)
extension HKHealthStore : QueryExecutor {}
