//
// Copyright (c) 2023 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// PROPRIETARY/CONFIDENTIAL
//
// Use is subject to license terms.
//

import XCTest
import SwiftUI
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

private class MockObserver: DataObserverDelegate {

    let key: String

    private(set) var value: String?

    private let observer: DataObserver<MockObserver>

    public init(
        key: String,
        dataStore: MockObjectStore = MockObjectStore()
    ) {
        self.key = key
        self.observer = dataStore.newObserver(id: key)
        self.observer.delegate = self
        self.value = self.observer.objects.first?.value
    }

    // MARK: - DataObserverDelegate

    func didAdd(object: KeyValue) {
        self.value = object.value
    }

    func didUpdate(object: KeyValue) {
        self.value = object.value
    }

    func didRemove(object: KeyValue) {
        self.value = nil
    }
}

// MARK: - ObserverTests

final class ObserverTests: XCTestCase {

    override func setUp() async throws {
        try? await KeyValueDataContainer.shared.load()
    }

    override func tearDown() async throws {
        let store = MockObjectStore()
        try await store.deleteAll()
    }

    func testIniitailValue() throws {
        let mockIdentifier = "mockIdentifier"
        let store = MockObjectStore()
        let observer = MockObserver(key: mockIdentifier)
        XCTAssertEqual(
            observer.value,
            nil
        )

        // Test updating the value for the key
        let mockValue = "mockValue"
        try store.createOrUpdate(KeyValue(
            identifier: mockIdentifier,
            value: mockValue
        ))
        XCTAssertEqual(
            observer.value,
            mockValue
        )

        // Test with another observer
        let anotherObserver = MockObserver(key: mockIdentifier)
        XCTAssertEqual(
            anotherObserver.value,
            mockValue
        )

        // Test udpating the value
        let anotherMockValue = "anotherMockValue"
        try store.createOrUpdate(KeyValue(
            identifier: mockIdentifier,
            value: anotherMockValue
        ))
        XCTAssertEqual(
            observer.value,
            anotherMockValue
        )

        // Test delete
        try store.deleteOne(id: mockIdentifier)
        XCTAssertEqual(
            observer.value,
            nil
        )
    }
}
