//
//  CodableStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - CodableStore

/// A protocol for key-value stores that persist ``Codable`` objects.
///
/// Conforming types provide async methods for storing, retrieving, and removing
/// values identified by string keys.
///
/// ```swift
/// let store: some CodableStore<MyModel> = ...
/// try await store.set(value: model, forKey: "key")
/// let retrieved = try await store.getValue(forKey: "key")
/// ```
public protocol CodableStore<PersistedType>: Sendable {

    associatedtype PersistedType: Codable & Sendable

    /// Stores a value for the given key, overwriting any existing value.
    ///
    /// Pass `nil` to remove the value for the key.
    ///
    /// - Parameter value: The value to persist, or `nil` to remove.
    /// - Parameter key: The key to associate with the value.
    func set(value: PersistedType?, forKey key: String) async throws

    /// Retrieves the value for the given key.
    ///
    /// - Parameter key: The key to look up.
    /// - Returns: The stored value, or `nil` if no value exists for the key.
    func getValue(forKey key: String) async throws -> PersistedType?

    /// Returns all keys currently stored.
    ///
    /// - Returns: An array of all keys in the store.
    func getAllKeys() async throws -> [String]

    /// Removes the value for the given key.
    ///
    /// - Parameter key: The key whose value should be removed.
    func removeValue(forKey key: String) async throws

    /// Removes all values from the store.
    func removeAllValues() async throws
}
