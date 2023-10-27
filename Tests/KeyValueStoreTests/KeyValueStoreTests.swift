//
//  KeyValueStoreTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import XCTest
@testable import KeyValueStore

// MARK: - Tests

class KeyValueStoreTests: XCTestCase {
    
    func testKeyValueStoreOperations() async throws {
        let mockKey = "MockKey"
        let mockValue = "MockValue"
        var result: String?
        let store = KeyValueStore()
        try? await KeyValueStore.configure()
        do {
            result = try await store.getValue(forKey: mockKey)
            XCTAssert(result == nil)
            
            try store.set(value: mockValue, forKey: mockKey)
            result = try await store.getValue(forKey: mockKey)
            XCTAssert(result == mockValue)
            
            try await store.removeValue(forKey: mockKey)
            result = try await store.getValue(forKey: mockKey)
            XCTAssert(result == nil)
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }
    
    func testKeyValueObserver() async throws {
        let mockKey = "MockKey"
        let mockValue = "MockValue"
        let store = KeyValueStore()
        let observer = KeyValueObserver(key: mockKey)
        try? await KeyValueStore.configure()
        do {
            XCTAssert(observer.value == nil)
            
            try store.set(value: mockValue, forKey: mockKey)
            XCTAssert(observer.value == mockValue)
            
            try await store.removeValue(forKey: mockKey)
            XCTAssert(observer.value == nil)
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }
}
