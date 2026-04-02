//
//  DiskBackedJSONCodableStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import Core

// MARK: - DiskBackedJSONCodableStore

/// A ``CodableStore`` that persists ``Codable`` values as a JSON file on disk.
///
/// Values are stored in a key-value dictionary serialized to JSON. An in-memory cache
/// avoids redundant disk reads. Thread safety is guaranteed by the actor isolation.
///
/// ```swift
/// let store = DiskBackedJSONCodableStore<MyModel>(
///     label: "myStore",
///     bundleIdentifier: Bundle.main.bundleIdentifier!
/// )
/// try await store.set(value: model, forKey: "key")
/// let value = try await store.getValue(forKey: "key")
/// ```
public actor DiskBackedJSONCodableStore<T: Codable & Sendable>: CodableStore {

    public typealias PersistedType = T

    private enum CachedValue {
        case uninitiated
        case initialized(value: [String: T])
    }

    private let label: String
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let fileSystem: FileSystem
    private let bundleIdentifier: String
    private var cachedDictionary: CachedValue = .uninitiated
    private var backingFileURL: URL?

    private var backingFileName: String {
        return "DiskBackedJSONCodableStore.\(self.label).json"
    }

    /// Creates a ``DiskBackedJSONCodableStore``.
    ///
    /// - Parameter label: A unique name for this store, also used in the backing file path.
    ///   **Must be unique across all instances in the application.**
    /// - Parameter jsonDecoder: The decoder for reading persisted JSON. Defaults to `JSONDecoder()`.
    /// - Parameter jsonEncoder: The encoder for writing JSON to disk. Defaults to `JSONEncoder()`.
    /// - Parameter fileSystem: The ``FileSystem`` implementation for I/O operations.
    /// - Parameter bundleIdentifier: The app's bundle identifier, used to scope the storage directory.
    init(
        label: String,
        jsonDecoder: JSONDecoder,
        jsonEncoder: JSONEncoder,
        fileSystem: FileSystem,
        bundleIdentifier: String
    ) {
        self.label = label
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        self.fileSystem = fileSystem
        self.bundleIdentifier = bundleIdentifier
    }

    /// Creates a ``DiskBackedJSONCodableStore`` with default JSON coding and file system.
    ///
    /// - Parameter label: A unique name for this store.
    ///   **Must be unique across all instances in the application.**
    /// - Parameter bundleIdentifier: The app's bundle identifier.
    public init(
        label: String,
        bundleIdentifier: String
    ) {
        self.init(
            label: label,
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            fileSystem: ConcreteFileSystem(),
            bundleIdentifier: bundleIdentifier
        )
    }

    // MARK: - CodableStore

    public func set(
        value: T?,
        forKey key: String
    ) throws {
        var currentDictionary = try self.getCachedDictionary()
        currentDictionary[key] = value
        try self.persist(cachedDictionary: currentDictionary)
    }

    public func getValue(forKey key: String) throws -> T? {
        let currentDictionary = try self.getCachedDictionary()
        return currentDictionary[key]
    }

    public func getAllKeys() throws -> [String] {
        let currentDictionary = try self.getCachedDictionary()
        return Array(currentDictionary.keys)
    }

    public func removeValue(forKey key: String) throws {
        try self.set(value: nil, forKey: key)
    }

    public func removeAllValues() throws {
        let backingFileURL = try self.getBackingFileURL()

        if self.fileSystem.fileExists(atURL: backingFileURL) {
            try self.fileSystem.delete(at: backingFileURL)
        }

        self.cachedDictionary = .initialized(value: [:])
    }

    // MARK: - Helpers

    private func persist(cachedDictionary: [String: T]) throws {
        let backingFileURL = try self.getBackingFileURL()

        let data: Data
        do {
            data = try self.jsonEncoder.encode(cachedDictionary)
        } catch {
            throw DiskBackedJSONCodableStoreError.writeFailure(cause: error)
        }

        do {
            try self.fileSystem.write(data: data, to: backingFileURL, options: .atomic)
        } catch {
            throw DiskBackedJSONCodableStoreError.writeFailure(cause: error)
        }

        self.cachedDictionary = .initialized(value: cachedDictionary)
    }

    private func getCachedDictionary() throws -> [String: T] {
        if case let .initialized(value) = self.cachedDictionary {
            return value
        }

        let backingFileURL = try self.getBackingFileURL()

        let data: Data
        if self.fileSystem.fileExists(atURL: backingFileURL) {
            do {
                data = try self.fileSystem.read(contensOf: backingFileURL, options: [])
            } catch {
                throw DiskBackedJSONCodableStoreError.readFailure(cause: error)
            }
        } else {
            data = Data()
        }

        let dictionary: [String: T]
        if data.isEmpty {
            dictionary = [:]
        } else {
            do {
                dictionary = try self.jsonDecoder.decode([String: T].self, from: data)
            } catch {
                throw DiskBackedJSONCodableStoreError.decodingFailure(cause: error)
            }
        }

        self.cachedDictionary = .initialized(value: dictionary)
        return dictionary
    }

    private func getBackingFileURL() throws -> URL {
        if let backingFileURL {
            return backingFileURL
        }

        let applicationSupportDirectoryURL: URL
        do {
            applicationSupportDirectoryURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
        } catch {
            throw DiskBackedJSONCodableStoreError.fileManagerError(cause: error)
        }

        let appBundleSupportDirectoryURL = applicationSupportDirectoryURL.appending(path: self.bundleIdentifier)

        do {
            try self.fileSystem.createDirectory(
                at: appBundleSupportDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            throw DiskBackedJSONCodableStoreError.fileManagerError(cause: error)
        }

        let backingFileURL = appBundleSupportDirectoryURL.appending(path: self.backingFileName)
        self.backingFileURL = backingFileURL

        return backingFileURL
    }
}
