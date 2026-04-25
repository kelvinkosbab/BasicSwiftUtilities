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

@Suite("DataObserver", .serialized)
struct ObserverTests {

    init() async throws {
        try? await KeyValueDataContainer.shared.load()
        let store = MockObjectStore()
        try? await store.deleteAll()
    }

    @Test("Observer tracks create, update, and delete")
    @MainActor func initialValue() throws {
        let mockIdentifier = "mockIdentifier"
        let store = MockObjectStore()
        let observer = try MockObserver(key: mockIdentifier)
        #expect(observer.value == nil)

        let mockValue = "mockValue"
        try store.createOrUpdate(KeyValue(identifier: mockIdentifier, value: mockValue))
        #expect(observer.value == mockValue)

        let anotherObserver = try MockObserver(key: mockIdentifier)
        #expect(anotherObserver.value == mockValue)

        let anotherMockValue = "anotherMockValue"
        try store.createOrUpdate(KeyValue(identifier: mockIdentifier, value: anotherMockValue))
        #expect(observer.value == anotherMockValue)

        try store.deleteOne(id: mockIdentifier)
        #expect(observer.value == nil)
    }
}
