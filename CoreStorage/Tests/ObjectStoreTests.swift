//
//  ObjectStoreTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import CoreData
@testable import CoreStorage

// MARK: - Mocks

private struct MockObjectStore: ObjectStore {

    typealias Object = KeyValue

    let container: PersistentDataContainer

    init() {
        self.container = KeyValueDataContainer.shared
    }
}

// MARK: - ObjectStoreTests

@Suite("ObjectStore", .serialized)
struct ObjectStoreTests {

    init() async throws {
        try? await KeyValueDataContainer.shared.load()
        let store = MockObjectStore()
        try? await store.deleteAll()
    }

    @Test("Create, update, and delete an object")
    @MainActor func createUpdateDeleteObject() throws {
        let identifier = "mockIdentifier"
        let object = KeyValue(identifier: identifier, value: "mockValue")
        let store = MockObjectStore()
        try store.createOrUpdate(object)

        var fetched = try store.fetchOne(id: identifier)
        #expect(fetched == object)

        let update = KeyValue(identifier: identifier, value: "mockValue2")
        try store.createOrUpdate(update)
        fetched = try store.fetchOne(id: identifier)
        #expect(fetched == update)

        try store.deleteOne(id: identifier)
    }

    @Test("Create, update, and delete an object (async)")
    func createUpdateDeleteObjectAsync() async throws {
        let identifier = "mockIdentifier"
        let object = KeyValue(identifier: identifier, value: "mockValue")
        let store = MockObjectStore()
        try await store.createOrUpdate(object)

        var fetched = try await store.fetchOne(id: identifier)
        #expect(fetched == object)

        let update = KeyValue(identifier: identifier, value: "mockValue2")
        try await store.createOrUpdate(update)
        fetched = try await store.fetchOne(id: identifier)
        #expect(fetched == update)

        try await store.deleteOne(id: identifier)
    }

    // MARK: - FetchAll

    @Test("Fetch all and fetch many return correct counts")
    @MainActor func fetchAll() throws {
        let store = MockObjectStore()
        let array = 0...10
        let identifiersToCreate: [String] = array.map { "identifier.\($0)" }

        for identifier in identifiersToCreate {
            try store.createOrUpdate(KeyValue(identifier: identifier, value: "value.\(identifier)"))
        }

        let fetchAllTest = try store.fetchAll()
        #expect(fetchAllTest.count == array.count)

        let fetchManyTest = try store.fetchMany(in: identifiersToCreate)
        #expect(fetchManyTest.count == array.count)

        try store.deleteMany(in: identifiersToCreate)
    }

    @Test("Fetch all and fetch many return correct counts (async)")
    func fetchAllAsync() async throws {
        let store = MockObjectStore()
        let array = 0...10
        let identifiersToCreate: [String] = array.map { "identifier.\($0)" }

        for identifier in identifiersToCreate {
            try await store.createOrUpdate(KeyValue(identifier: identifier, value: "value.\(identifier)"))
        }

        let fetchAllTest = try await store.fetchAll()
        #expect(fetchAllTest.count == array.count)

        let fetchManyTest = try await store.fetchMany(in: identifiersToCreate)
        #expect(fetchManyTest.count == array.count)

        try await store.deleteMany(in: identifiersToCreate)
    }

    // MARK: - NotIn

    @Test("Fetch many not-in excludes the specified identifier")
    @MainActor func notInSync() throws {
        let store = MockObjectStore()
        let array = 0...10
        let identifiersToCreate: [String] = array.map { "identifier.\($0)" }

        for identifier in identifiersToCreate {
            try store.createOrUpdate(KeyValue(identifier: identifier, value: "value.\(identifier)"))
        }

        let identifierToIgnore = identifiersToCreate[0]

        let notInFirstId = try store.fetchMany(notIn: [identifierToIgnore])
        #expect(notInFirstId.count == array.count - 1)

        try store.deleteMany(notIn: [identifierToIgnore])
        try store.deleteOne(id: identifierToIgnore)
    }

    @Test("Fetch many not-in excludes the specified identifier (async)")
    func notInAsync() async throws {
        let store = MockObjectStore()
        let array = 0...10
        let identifiersToCreate: [String] = array.map { "identifier.\($0)" }

        for identifier in identifiersToCreate {
            try await store.createOrUpdate(KeyValue(identifier: identifier, value: "value.\(identifier)"))
        }

        let identifierToIgnore = identifiersToCreate[0]

        let notInFirstId = try await store.fetchMany(notIn: [identifierToIgnore])
        #expect(notInFirstId.count == array.count - 1)

        try await store.deleteMany(notIn: [identifierToIgnore])
        try await store.deleteOne(id: identifierToIgnore)
    }
}
