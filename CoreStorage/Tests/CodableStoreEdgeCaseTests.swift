//
//  CodableStoreEdgeCaseTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import Foundation
@testable import CoreStorage

// MARK: - Mock FileSystem

private final class FailingFileSystem: FileSystem, @unchecked Sendable {
    var shouldFailRead = false
    var shouldFailWrite = false
    var storage: [String: Data] = [:]
    var directories: Set<String> = []

    func read(contensOf url: URL, options: Data.ReadingOptions) throws -> Data {
        if shouldFailRead {
            throw NSError(domain: "FailingFS", code: 1)
        }
        guard let data = storage[url.path] else {
            throw NSError(domain: "FailingFS", code: 2)
        }
        return data
    }

    func write(data: Data, to url: URL, options: Data.WritingOptions) throws {
        if shouldFailWrite {
            throw NSError(domain: "FailingFS", code: 3)
        }
        storage[url.path] = data
    }

    func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws {
        directories.insert(url.path)
    }

    func delete(at url: URL) throws {
        storage.removeValue(forKey: url.path)
    }

    func fileExists(atPath path: String) -> Bool {
        return storage[path] != nil
    }
}

// MARK: - Test Model

private struct Item: Codable, Sendable, Equatable {
    let value: Int
}

// MARK: - CodableStore Edge Case Tests

@Suite("DiskBackedJSONCodableStore Edge Cases", .serialized)
struct CodableStoreEdgeCaseTests {

    @Test("Read failure throws readFailure error")
    func readFailureThrowsCorrectError() async {
        let fs = FailingFileSystem()
        let label = "read-fail-\(UUID().uuidString)"

        // First write a value so the backing file exists
        let store = DiskBackedJSONCodableStore<Item>(
            label: label,
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            fileSystem: fs,
            bundleIdentifier: "com.test"
        )
        try? await store.set(value: Item(value: 1), forKey: "k")

        // Enable read failures and create a fresh store with the same label
        fs.shouldFailRead = true
        let store2 = DiskBackedJSONCodableStore<Item>(
            label: label,
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            fileSystem: fs,
            bundleIdentifier: "com.test"
        )

        await #expect(throws: DiskBackedJSONCodableStoreError.self) {
            _ = try await store2.getValue(forKey: "k")
        }
    }

    @Test("Write failure throws writeFailure error")
    func writeFailureThrowsCorrectError() async {
        let fs = FailingFileSystem()
        fs.shouldFailWrite = true
        let store = DiskBackedJSONCodableStore<Item>(
            label: "write-fail-\(UUID().uuidString)",
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            fileSystem: fs,
            bundleIdentifier: "com.test"
        )

        await #expect(throws: DiskBackedJSONCodableStoreError.self) {
            try await store.set(value: Item(value: 1), forKey: "k")
        }
    }

    @Test("Decoding failure throws decodingFailure error")
    func decodingFailureThrowsCorrectError() async {
        let fs = FailingFileSystem()
        let label = "decode-fail-\(UUID().uuidString)"
        let store = DiskBackedJSONCodableStore<Item>(
            label: label,
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            fileSystem: fs,
            bundleIdentifier: "com.test"
        )

        // Write valid data to establish the backing file
        try? await store.set(value: Item(value: 1), forKey: "k")

        // Corrupt the stored data
        for key in fs.storage.keys where key.contains(label) {
            fs.storage[key] = Data("not valid json".utf8)
        }

        // New store with same label will try to read the corrupt data
        let store2 = DiskBackedJSONCodableStore<Item>(
            label: label,
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            fileSystem: fs,
            bundleIdentifier: "com.test"
        )

        await #expect(throws: DiskBackedJSONCodableStoreError.self) {
            _ = try await store2.getValue(forKey: "k")
        }
    }

    @Test("Multiple keys coexist independently")
    func multipleKeysCoexist() async throws {
        let fs = FailingFileSystem()
        let store = DiskBackedJSONCodableStore<Item>(
            label: "multi-\(UUID().uuidString)",
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            fileSystem: fs,
            bundleIdentifier: "com.test"
        )

        try await store.set(value: Item(value: 1), forKey: "a")
        try await store.set(value: Item(value: 2), forKey: "b")
        try await store.set(value: Item(value: 3), forKey: "c")

        #expect(try await store.getValue(forKey: "a") == Item(value: 1))
        #expect(try await store.getValue(forKey: "b") == Item(value: 2))
        #expect(try await store.getValue(forKey: "c") == Item(value: 3))

        try await store.removeValue(forKey: "b")
        #expect(try await store.getValue(forKey: "a") == Item(value: 1))
        #expect(try await store.getValue(forKey: "b") == nil)
        #expect(try await store.getValue(forKey: "c") == Item(value: 3))
    }
}
