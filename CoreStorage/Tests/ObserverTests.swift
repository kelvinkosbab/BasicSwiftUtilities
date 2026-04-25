//
//  ObserverTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import SwiftUI
import CoreData
@testable import CoreStorage

// MARK: - Mocks

private struct MockObjectStore: ObjectStore {

    typealias Object = KeyValue

    let container: PersistentDataContainer

    /// Creates a `MockObjectStore` backed by a fresh in-memory container so each test
    /// instance is fully isolated from every other test.
    init() {
        let freshContainer = KeyValueDataContainer()
        freshContainer.coreDataContainer.loadPersistentStores { _, _ in
            // In-memory store loads synchronously; nothing to do here.
        }
        self.container = freshContainer
    }
}

private class MockObserver: DataObserverDelegate {

    let key: String

    private(set) var value: String?

    private let observer: DataObserver<MockObserver>

    public init(
        key: String,
        dataStore: MockObjectStore
    ) throws {
        self.key = key
        self.observer = try dataStore.newObserver(id: key)
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

@Suite("DataObserver")
struct ObserverTests {

    @Test("Observer tracks create, update, and delete events for the watched identifier")
    @MainActor func initialValue() throws {
        let mockIdentifier = "mockIdentifier"
        let store = MockObjectStore()
        let observer = try MockObserver(key: mockIdentifier, dataStore: store)
        #expect(observer.value == nil)

        let mockValue = "mockValue"
        try store.createOrUpdate(KeyValue(identifier: mockIdentifier, value: mockValue))
        #expect(observer.value == mockValue)

        let anotherObserver = try MockObserver(key: mockIdentifier, dataStore: store)
        #expect(anotherObserver.value == mockValue)

        let anotherMockValue = "anotherMockValue"
        try store.createOrUpdate(KeyValue(identifier: mockIdentifier, value: anotherMockValue))
        #expect(observer.value == anotherMockValue)

        try store.deleteOne(id: mockIdentifier)
        #expect(observer.value == nil)
    }
}
