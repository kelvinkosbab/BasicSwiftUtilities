//
// Copyright (c) 2023 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// PROPRIETARY/CONFIDENTIAL
//
// Use is subject to license terms.
//

import XCTest
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

final class ObjectStoreTests: XCTestCase {

    override func setUp() async throws {
        try? await KeyValueDataContainer.shared.load()
    }

    override func tearDown() async throws {
        let store = MockObjectStore()
        try await store.deleteAll()
    }

    func testCreateUpdateDeleteObject() throws {
        let identifier = "mockIdentifier"
        let object = KeyValue(identifier: identifier, value: "mockValue")
        let store = MockObjectStore()
        try store.createOrUpdate(object)

        // Fetch and verify created object
        var fetched = try store.fetchOne(id: identifier)
        XCTAssertEqual(
            fetched,
            object
        )

        // Update, fetch, and verify update object
        let update = KeyValue(identifier: identifier, value: "mockValue2")
        try store.createOrUpdate(update)
        fetched = try store.fetchOne(id: identifier)
        XCTAssertEqual(
            fetched,
            update
        )

        // Delete the object
        try store.deleteOne(id: identifier)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testCreateUpdateDeleteObjectAsync() async throws {
        let identifier = "mockIdentifier"
        let object = KeyValue(identifier: identifier, value: "mockValue")
        let store = MockObjectStore()
        try await store.createOrUpdate(object)

        // Fetch and verify created object
        var fetched = try await store.fetchOne(id: identifier)
        XCTAssertEqual(
            fetched,
            object
        )

        // Update, fetch, and verify update object
        let update = KeyValue(identifier: identifier, value: "mockValue2")
        try await store.createOrUpdate(update)
        fetched = try await store.fetchOne(id: identifier)
        XCTAssertEqual(
            fetched,
            update
        )

        // Delete the object
        try await store.deleteOne(id: identifier)
    }

    // MARK: - FetchAll

    func testFetchAll() throws {
        let store = MockObjectStore()
        let array = 0...10
        let identifiersToCreate: [String] = array.map { identifier in
            "identifier.\(identifier)"
        }

        for identifier in identifiersToCreate {
            let object = KeyValue(
                identifier: identifier,
                value: "value.\(identifier)"
            )
            try store.createOrUpdate(object)
        }

        // Test fetchAll
        let fetchAllTest = try store.fetchAll()
        XCTAssertEqual(
            fetchAllTest.count,
            array.count
        )

        // Test fetchMany
        let fetchManyTest = try store.fetchMany(in: identifiersToCreate)
        XCTAssertEqual(
            fetchManyTest.count,
            array.count
        )

        // Test deleteMany
        try store.deleteMany(in: identifiersToCreate)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testFetchAllAsync() async throws {
        let store = MockObjectStore()
        let array = 0...10
        let identifiersToCreate: [String] = array.map { identifier in
            "identifier.\(identifier)"
        }

        for identifier in identifiersToCreate {
            let object = KeyValue(
                identifier: identifier,
                value: "value.\(identifier)"
            )
            try await store.createOrUpdate(object)
        }

        // Test fetchAll
        let fetchAllTest = try await store.fetchAll()
        XCTAssertEqual(
            fetchAllTest.count,
            array.count
        )

        // Test fetchMany
        let fetchManyTest = try await store.fetchMany(in: identifiersToCreate)
        XCTAssertEqual(
            fetchManyTest.count,
            array.count
        )

        // Test deleteMany
        try await store.deleteMany(in: identifiersToCreate)
    }

    // MARK: - NotIn

    func testNotIn() throws {
        let store = MockObjectStore()
        let array = 0...10
        let identifiersToCreate: [String] = array.map { identifier in
            "identifier.\(identifier)"
        }

        for identifier in identifiersToCreate {
            let object = KeyValue(
                identifier: identifier,
                value: "value.\(identifier)"
            )
            try store.createOrUpdate(object)
        }

        guard let identifierToIgnore = identifiersToCreate.first else {
            XCTFail("We need an ID to ignore to finish this test")
            return
        }

        // Tests fetch many not in
        let notInFirstId = try store.fetchMany(notIn: [ identifierToIgnore ])
        XCTAssertEqual(
            notInFirstId.count,
            array.count - 1
        )

        // Tests delete many not in
        try store.deleteMany(notIn: [ identifierToIgnore ])
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testNotIn() async throws {
        let store = MockObjectStore()
        let array = 0...10
        let identifiersToCreate: [String] = array.map { identifier in
            "identifier.\(identifier)"
        }

        for identifier in identifiersToCreate {
            let object = KeyValue(
                identifier: identifier,
                value: "value.\(identifier)"
            )
            try await store.createOrUpdate(object)
        }

        guard let identifierToIgnore = identifiersToCreate.first else {
            XCTFail("We need an ID to ignore to finish this test")
            return
        }

        // Tests fetch many not in
        let notInFirstId = try await store.fetchMany(notIn: [ identifierToIgnore ])
        XCTAssertEqual(
            notInFirstId.count,
            array.count - 1
        )

        // Tests delete many not in
        try await store.deleteMany(notIn: [ identifierToIgnore ])
    }
}
