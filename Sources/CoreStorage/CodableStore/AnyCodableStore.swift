//
//  AnyCodableStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - AnyCodableStore

/// A type-erased wrapper around a ``CodableStore``.
///
/// Use this when you need to store or pass around a ``CodableStore`` without exposing
/// the concrete type.
///
/// ```swift
/// let concreteStore = DiskBackedJSONCodableStore<MyModel>(label: "store", bundleIdentifier: "com.app")
/// let erased = concreteStore.eraseToAnyCodableStore()
/// try await erased.set(value: model, forKey: "key")
/// ```
public final class AnyCodableStore<T: Codable & Sendable>: CodableStore, @unchecked Sendable {

    public typealias PersistedType = T

    private let setValueDelegate: @Sendable (T?, String) async throws -> Void
    private let getValueDelegate: @Sendable (String) async throws -> T?
    private let getAllKeysDelegate: @Sendable () async throws -> [String]
    private let removeValueDelegate: @Sendable (String) async throws -> Void
    private let removeAllValuesDelegate: @Sendable () async throws -> Void

    /// Creates a type-erased store wrapping the given concrete store.
    ///
    /// - Parameter delegate: The concrete ``CodableStore`` to wrap.
    public init<U: CodableStore>(_ delegate: U) where U.PersistedType == PersistedType {
        self.setValueDelegate = delegate.set
        self.getValueDelegate = delegate.getValue
        self.getAllKeysDelegate = delegate.getAllKeys
        self.removeValueDelegate = delegate.removeValue
        self.removeAllValuesDelegate = delegate.removeAllValues
    }

    public func set(value: T?, forKey key: String) async throws {
        try await self.setValueDelegate(value, key)
    }

    public func getValue(forKey key: String) async throws -> T? {
        return try await self.getValueDelegate(key)
    }

    public func getAllKeys() async throws -> [String] {
        return try await getAllKeysDelegate()
    }

    public func removeValue(forKey key: String) async throws {
        try await self.removeValueDelegate(key)
    }

    public func removeAllValues() async throws {
        try await self.removeAllValuesDelegate()
    }
}

// MARK: - Type Erasure Helpers

/// Convenience method for erasing the concrete ``CodableStore`` type.
public extension CodableStore {

    /// Wraps this store in an ``AnyCodableStore`` for type erasure.
    func eraseToAnyCodableStore() -> AnyCodableStore<PersistedType> {
        return AnyCodableStore<PersistedType>(self)
    }
}
