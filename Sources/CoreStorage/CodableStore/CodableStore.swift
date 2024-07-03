//
//  CodableStore.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - CodableStore

/// An entity that can store `Codable` objects by key.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public protocol CodableStore: AnyObject {

    associatedtype PersistedType: Codable

    /// Asynchronously stores the provided `Codable` in the `CodableStore` with the provided `key`,
    /// Overwriting the previous value in the store with the same key if applicable.
    ///
    /// - Parameter value: The `Codable` value to persist.
    /// - Parameter key: The key for the value to persist.
    func set(value: PersistedType?, forKey key: String) async throws

    /// Asynchronously gets the previously-set `value` for the given `key` from the `CodableStore`.
    ///
    /// - Parameter key: The key for the value to retrieve.
    ///
    /// - Returns: The value stored in the `CodableStore` with the provided `key`.
    func getValue(forKey key: String) async throws -> PersistedType?

    /// Asynchronously gets all the keys from the `CodableStore`.
    ///
    /// - Returns: All the keys stored in the `CodableStore`.
    func getAllKeys() async throws -> [String]

    /// Asynchronously removes the value of the provided `key` `String` from the `CodableStore`.
    ///
    /// - Parameter key: The key of the value to remove.
    func removeValue(forKey key: String) async throws

    /// Asynchronously removes all of the values from the `CodableStore`.
    func removeAllValues() async throws
}
