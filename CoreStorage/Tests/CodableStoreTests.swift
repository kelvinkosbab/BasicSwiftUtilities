//
//  CodableStoreTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import Foundation
@testable import CoreStorage

// MARK: - Test Model

private struct TestModel: Codable, Sendable, Equatable {
    let id: String
    let name: String
}

// MARK: - Mock FileSystem

private final class MockFileSystem: FileSystem, @unchecked Sendable {
    var storage: [String: Data] = [:]
    var directories: Set<String> = []

    func read(contensOf url: URL, options: Data.ReadingOptions) throws -> Data {
        guard let data = storage[url.path] else {
            throw NSError(domain: "MockFileSystem", code: 1, userInfo: [NSLocalizedDescriptionKey: "File not found"])
        }
        return data
    }

    func write(data: Data, to url: URL, options: Data.WritingOptions) throws {
        storage[url.path] = data
    }

    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]?) throws {
        directories.insert(url.path)
    }

    func delete(at url: URL) throws {
        storage.removeValue(forKey: url.path)
    }

    func fileExists(atPath path: String) -> Bool {
        return storage[path] != nil
    }
}

// MARK: - CodableStoreTests

@Suite("DiskBackedJSONCodableStore", .serialized)
struct CodableStoreTests {

    @Test("Set and get a value")
    func setAndGetValue() async throws {
        let store = makeStore()
        let model = TestModel(id: "1", name: "Test")

        try await store.set(value: model, forKey: "key1")
        let retrieved = try await store.getValue(forKey: "key1")

        #expect(retrieved == model)
    }

    @Test("Get value returns nil for missing key")
    func getValueReturnsNilForMissingKey() async throws {
        let store = makeStore()
        let value = try await store.getValue(forKey: "nonexistent")
        #expect(value == nil)
    }

    @Test("Remove a value")
    func removeValue() async throws {
        let store = makeStore()
        let model = TestModel(id: "1", name: "Test")

        try await store.set(value: model, forKey: "key1")
        try await store.removeValue(forKey: "key1")

        let retrieved = try await store.getValue(forKey: "key1")
        #expect(retrieved == nil)
    }

    @Test("Get all keys")
    func getAllKeys() async throws {
        let store = makeStore()

        try await store.set(value: TestModel(id: "1", name: "A"), forKey: "alpha")
        try await store.set(value: TestModel(id: "2", name: "B"), forKey: "beta")
        try await store.set(value: TestModel(id: "3", name: "C"), forKey: "gamma")

        let keys = try await store.getAllKeys()
        #expect(keys.sorted() == ["alpha", "beta", "gamma"])
    }

    @Test("Remove all values")
    func removeAllValues() async throws {
        let store = makeStore()

        try await store.set(value: TestModel(id: "1", name: "A"), forKey: "key1")
        try await store.set(value: TestModel(id: "2", name: "B"), forKey: "key2")

        try await store.removeAllValues()

        let keys = try await store.getAllKeys()
        #expect(keys.isEmpty)
    }

    @Test("Overwriting a value replaces the old one")
    func overwriteValue() async throws {
        let store = makeStore()

        try await store.set(value: TestModel(id: "1", name: "Original"), forKey: "key1")
        try await store.set(value: TestModel(id: "1", name: "Updated"), forKey: "key1")

        let retrieved = try await store.getValue(forKey: "key1")
        #expect(retrieved?.name == "Updated")
    }

    @Test("Setting nil removes the value")
    func setNilRemovesValue() async throws {
        let store = makeStore()
        try await store.set(value: TestModel(id: "1", name: "A"), forKey: "key1")
        try await store.set(value: nil, forKey: "key1")

        let retrieved = try await store.getValue(forKey: "key1")
        #expect(retrieved == nil)
    }

    @Test("Type erasure via AnyCodableStore works correctly")
    func typeErasure() async throws {
        let concreteStore = makeStore()
        let erased = concreteStore.eraseToAnyCodableStore()

        let model = TestModel(id: "1", name: "Erased")
        try await erased.set(value: model, forKey: "key1")
        let retrieved = try await erased.getValue(forKey: "key1")
        #expect(retrieved == model)
    }

    // MARK: - Helpers

    private func makeStore() -> DiskBackedJSONCodableStore<TestModel> {
        let fileSystem = MockFileSystem()
        return DiskBackedJSONCodableStore<TestModel>(
            label: "test-\(UUID().uuidString)",
            jsonDecoder: JSONDecoder(),
            jsonEncoder: JSONEncoder(),
            fileSystem: fileSystem,
            bundleIdentifier: "com.test.codablestore"
        )
    }
}
