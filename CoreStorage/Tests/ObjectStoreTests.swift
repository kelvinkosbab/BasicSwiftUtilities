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

    /// Creates a `MockObjectStore` backed by a fresh in-memory container so each test
    /// instance is fully isolated from every other test.
    ///
    /// `NSInMemoryStoreType` loads synchronously, so we can safely build the container
    /// without awaiting.
    init() {
        let freshContainer = KeyValueDataContainer()
        freshContainer.coreDataContainer.loadPersistentStores { _, _ in
            // In-memory store loads synchronously; nothing to do here.
        }
        self.container = freshContainer
    }
}

// MARK: - ObjectStoreTests

@Suite("ObjectStore")
struct ObjectStoreTests {

    @Test("Create, update, and delete an object via sync API")
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

    @Test("Create, update, and delete an object via async API")
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

    @Test("fetchAll and fetchMany return all created objects via sync API")
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

    @Test("fetchAll and fetchMany return all created objects via async API")
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

    @Test("fetchMany(notIn:) excludes the specified identifier via sync API")
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

    @Test("fetchMany(notIn:) excludes the specified identifier via async API")
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
