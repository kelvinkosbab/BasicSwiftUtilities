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

private enum MockError: Error {
    case mock
}

private class MockCoreDataContainer: CoreDataPersistentContainer {

    let containerLoadError: Error?

    init(
        containerLoadError: Error?,
        persistentStoreDescriptions: [NSPersistentStoreDescription] = []
    ) {
        self.containerLoadError = containerLoadError
        self.persistentStoreDescriptions = persistentStoreDescriptions
    }

    let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    var persistentStoreDescriptions: [NSPersistentStoreDescription] = []

    func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        let description = NSPersistentStoreDescription()
        DispatchQueue.main.async {
            block(description, self.containerLoadError)
        }
    }
}

private struct MockPersistentDataContainer: PersistentDataContainer {

    var coreDataContainer: CoreDataPersistentContainer

    init(containerLoadError: Error? = nil) {
        self.coreDataContainer = MockCoreDataContainer(containerLoadError: containerLoadError)
    }

    init(container: CoreDataPersistentContainer) {
        self.coreDataContainer = container
    }
}

// MARK: - PersistentDataContainerTests

final class PersistentDataContainerTests: XCTestCase {

    let expectedStoreName = "KeyValueDataModel"

    // MARK: - Init tests

    func testShouldThrowForInvalidStoreNameInBundle() throws {
        let mockInvalidStoreName = "This is definitely not a valid store name"
        do {
            _ = try MockPersistentDataContainer(
                storeName: mockInvalidStoreName,
                in: .module
            )
            XCTFail("This is expected to throw")
        } catch {
            // This is expected to throw
        }
    }

    func testShouldThrowForInvalidModelURL() throws {
        do {
            _ = try MockPersistentDataContainer(
                storeName: self.expectedStoreName,
                modelUrl: URL(string: "anInvalidUrl.com")!
            )
            XCTFail("This is expected to throw")
        } catch {
            // This is expected to throw
        }
    }

    func testShouldNotThrowForValidInit() throws {
        _ = try MockPersistentDataContainer(
            storeName: self.expectedStoreName,
            in: .module
        )
    }

    // MARK: - Load tests

    func testLoadThrows() async throws {
        let container = MockPersistentDataContainer(containerLoadError: MockError.mock)
        do {
            try await container.load()
        } catch {
            // expected to throw
        }
    }

    func testLoadSucceeds() async throws {
        let container = try MockPersistentDataContainer(
            storeName: self.expectedStoreName,
            in: .module
        )
        try await container.load()
    }

    // MARK: - File protection level tests

    func testSetFileProtectionType() throws {
        let coreDataContainer = MockCoreDataContainer(
            containerLoadError: nil,
            persistentStoreDescriptions: []
        )
        let container = MockPersistentDataContainer(container: coreDataContainer)
        container.configure(fileProtectionType: .complete)
        XCTAssertEqual(
            coreDataContainer.persistentStoreDescriptions.count,
            1
        )
    }
}
