//
//  CoreDataContainerTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import XCTest
import CoreData
import CoreStorage

// MARK: - Mocks

//private struct MockCoreDataContainer : PersistentDataContainer {
//    
//    let storeName: String
//    let persistentContainer: NSPersistentContainer
//    
//    init() throws {
//        try self.init(storeName: "YourCoreDataModelName", in: .module)
//    }
//    
//    init(
//        storeName: String,
//        container: NSPersistentContainer
//    ) {
//        self.storeName = storeName
//        self.persistentContainer = container
//    }
//}

// MARK: - Tests

class CoreDataContainerTests : XCTestCase {
    
    /// Test requirements:
    /// - Constructing `MockCoreDataContainer` should not throw.
    /// - Loading the container via `container.load(_:)` should throw on the second call.
    func testThrowsErrorIfContainerLoadedTwice() async throws {
//        let container = try MockCoreDataContainer()
//        do {
//            try await container.load()
//        } catch {
//            XCTFail("First call should not throw")
//        }
//        do {
//            try await container.load()
//            XCTFail("Second call should throw error")
//        } catch {
//            // should throw error
//        }
    }
    
    /**
     func testShouldThrowIfModelIsLoadedTwice() async throws {
         do {
             try await KeyValueModelContainer.shared.load()
         } catch {
             XCTFail("Initial configure should not throw")
         }
         
         do {
             try await KeyValueModelContainer.shared.load()
             XCTFail("Second configure should throw")
         } catch {
             // Throw is expected (NSUnderlyingException: Can't add the same store twice)
         }
     }
     */
}
