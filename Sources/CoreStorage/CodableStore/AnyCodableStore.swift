//
//  AnyCodableStore.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - AnyCodableStore

/// A class that erases the type of a backing `CodableStore` so that it can be used without elaborate
/// associated type constraints.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public final class AnyCodableStore<T: Codable>: CodableStore {

    public typealias PersistedType = T

    private let setValueDelegate: (T?, String) async throws -> Void
    private let getValueDelegate: (String) async throws -> T?
    private let getAllKeysDelegate: () async throws -> [String]
    private let removeValueDelegate: (String) async throws -> Void
    private let removeAllValuesDelegate: () async throws -> Void

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

// Extensions for helping with Swift's protocol type erasure.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension CodableStore {

    func eraseMyType() -> AnyCodableStore<PersistedType> {
        return AnyCodableStore<PersistedType>(self)
    }
}
