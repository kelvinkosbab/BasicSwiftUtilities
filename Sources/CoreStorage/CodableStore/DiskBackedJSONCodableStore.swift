//
//  DiskBackedJSONCodableStore.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import Core

// MARK: - DiskBackedJSONCodableStore

/// A `CodableStore` that persists a `Codable` as a JSON file on disk.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public class DiskBackedJSONCodableStore<T: Codable> : CodableStore {
    
    public typealias PersistedType = T
    
    private enum CachedValue<CodablePersistedType: Codable> {
        case uninitiated
        case initialized(value: [String: CodablePersistedType])
    }
    
    private let label: String
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let fileSystem: FileSystem
    internal let workQueue: DispatchQueue
    private let bundleIdentifier: String
    private var cachedDisctionary: CachedValue<T> = .uninitiated
    private var backingFileURL: URL?
    
    private var backingFileName: String {
        return "DiskBackedJSONCodableStore.\(self.label).json"
    }
    
    /// Constructs a `DiskBackedJSONCodableStore`.
    ///
    /// - Parameter label: The name of the `DiskBackedJSONCodableStore`. This value is also used as part of the
    /// URL for the file backing the `DiskBackeJSONCodableStore`.
    /// **This must be unique across all the instances in the application.**
    /// - Parameter jsonDecoder: The `JSONDecoder` used to deserialize the `Codable` read from disk.
    /// - Parameter jsonEncoder: The `JSONEncoder` used to serialize the `Codable` written to disk.
    /// - Parameter fileSystem: A `FileSystem` implementation taht allows this store to read-from and write-to the file system.
    /// - Parameter workQueue: The `DispatchQueue` used to serialize requests to the `DiskBackedJSONCodableStore`.
    /// - Parameter bundleIdentifier: The app's bundle identifier.
    init(
        label: String,
        jsonDecoder: JSONDecoder,
        jsonEncoder: JSONEncoder,
        fileSystem: FileSystem,
        workQueue: DispatchQueue,
        bundleIdentifier: String
    ) {
        self.label = label
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        self.fileSystem = fileSystem
        self.workQueue = workQueue
        self.bundleIdentifier = bundleIdentifier
    }
    
    /// Constructs a `DiskBackedJSONCodableStore`.
    ///
    /// - Parameter label: The name of the `DiskBackedJSONCodableStore`. This value is also used as part of the
    /// URL for the file backing the `DiskBackeJSONCodableStore`.
    /// **This must be unique across all the instances in the application.**
    /// - Parameter qos:: The quality of service that this store is expected to provide when completing its operations. If the
    /// results of a read operation are intended to be presented to the customer, for instance, a caller should choose
    /// `.userInitiated` in order to keep the necessary resources available for that level of responsiveness.
    /// - Parameter bundleIdentifier: The app's bundle identifier.
    public convenience init(
        label: String,
        qos: DispatchQoS = .utility,
        bundleIdentifier: String
    ) {
        self.init(
            label: label,
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            fileSystem: ConcreteFileSystem(),
            workQueue: DispatchQueue(
                label: "DiskBackedJSONStore.\(label)",
                qos: qos
            ),
            bundleIdentifier: bundleIdentifier
        )
    }
    
    // MARK: - CodableStore
    
    public func set(
        value: T?,
        forKey key: String
    ) async throws {
        try await withCheckedThrowingVoidContinuation { continuation in
            self.workQueue.async {
                do {
                    
                    // Get the current value of the cached `Dictionary`
                    var currentDictionary = try self.getCachedDictionary()
                    
                    // The Swift Dictionary data structure is a struct, which is a value type.
                    // By assigning the cached Dictionary to a new member variable, we
                    // automatically get a (shallow) copy of the dictionary that we can freely
                    // mutate here.
                    currentDictionary[key] = value
                    
                    // Persist the new Dictionary
                    try self.set(cachedDictionary: currentDictionary)
                    
                    continuation.resume()
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func getValue(forKey key: String) async throws -> T? {
        try await withCheckedThrowingContinuation { continuation in
            self.workQueue.async {
                do {
                    let currentDictionary = try self.getCachedDictionary()
                    continuation.resume(returning: currentDictionary[key])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func getAllKeys() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            self.workQueue.async {
                do {
                    let currentDictionary = try self.getCachedDictionary()
                    continuation.resume(returning: Array(currentDictionary.keys))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func removeValue(forKey key: String) async throws {
        try await self.set(value: nil, forKey: key)
    }
    
    public func removeAllValues() async throws {
        try await withCheckedThrowingVoidContinuation { continuation in
            self.workQueue.async {
                do {
                    // We cannot rely on the `setVachedDictionary` method here because that method
                    // relies on the cache being in a good state. As a safeuard, when
                    // `internalRemoveAllValues` is called we directory remove the backing file
                    // from the file system.
                    let backingFileURL = try self.getBackingFileURL()
                    
                    if self.fileSystem.fileExists(atURL: backingFileURL) {
                        try self.fileSystem.delete(at: backingFileURL)
                    }
                    
                    // Persist the new empty vlue to the in-memory cache.
                    self.cachedDisctionary = .initialized(value: [:])
                    
                    continuation.resume()
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func set(cachedDictionary: [String: T]) throws {
        
        // We always need to try to propagate the write to disk in this case.
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
        
        // Persist the value to the in-memory cache after the disk cache is initialized.
        self.cachedDisctionary = .initialized(value: cachedDictionary)
    }
    
    private func getCachedDictionary() throws -> [String: T] {
        
        // If we already have a chached version in memory, use it.
        if case let .initialized(value) = self.cachedDisctionary {
            return value
        }
        
        // Otherwise, we need to read the value from disk.
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
        
        // Persist the value to the in-memory cache
        self.cachedDisctionary = .initialized(value: dictionary)
        
        return dictionary
    }
    
    private func getBackingFileURL() throws -> URL {
        
        // Use the cached value if possible.
        if let backingFileURL {
            return backingFileURL
        }
        
        // Otherwise, build the URL of the backing file based on the
        // Application Support directory for this app.
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
        
        // Once we have the Application Support directory for this app, we need to ensure that
        // it exists. The FIleManger API is fairly unusual here -- if `withIntermediateDirectories`
        // is set to `true`, then the method will succeed even if the directory already exists.
        // (Note that if `withIntermediateDirectories` is `false`, then `createDirectory` will
        // throw if the directory already exists.)
        //
        // For more info see [Apple's documentation for `FileManager:createDirectory`](https://developer.apple.com/documentation/foundation/filemanager/1415371-createdirectory).
        let appBundleSupportDirectoryURL: URL
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            appBundleSupportDirectoryURL = applicationSupportDirectoryURL.appending(path: self.bundleIdentifier)
        } else {
            appBundleSupportDirectoryURL = applicationSupportDirectoryURL.appendingPathComponent(self.bundleIdentifier)
        }
        
        do {
            try self.fileSystem.createDirectory(
                at: appBundleSupportDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            throw DiskBackedJSONCodableStoreError.fileManagerError(cause: error)
        }
        
        let backingFileURL: URL
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            backingFileURL = appBundleSupportDirectoryURL.appending(path: self.backingFileName)
        } else {
            backingFileURL = applicationSupportDirectoryURL.appendingPathComponent(self.backingFileName)
        }
        self.backingFileURL = backingFileURL
        
        return backingFileURL
    }
}
