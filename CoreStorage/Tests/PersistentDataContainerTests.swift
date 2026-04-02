//
//  PersistentDataContainerTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import CoreData
@testable import CoreStorage

// MARK: - Mocks

private enum MockError: Error {
    case mock
}

private final class MockCoreDataContainer: CoreDataPersistentContainer, @unchecked Sendable {

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

    func loadPersistentStores(completionHandler block: @escaping @Sendable (NSPersistentStoreDescription, Error?) -> Void) {
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

@Suite("PersistentDataContainer")
struct PersistentDataContainerTests {

    let expectedStoreName = "KeyValueDataModel"

    // MARK: - Init tests

    @Test("Throws for invalid store name in bundle")
    func shouldThrowForInvalidStoreNameInBundle() throws {
        let mockInvalidStoreName = "This is definitely not a valid store name"
        #expect(throws: (any Error).self) {
            _ = try MockPersistentDataContainer(
                storeName: mockInvalidStoreName,
                in: .module
            )
        }
    }

    @Test("Throws for invalid model URL")
    func shouldThrowForInvalidModelURL() throws {
        #expect(throws: (any Error).self) {
            _ = try MockPersistentDataContainer(
                storeName: self.expectedStoreName,
                modelUrl: URL(string: "anInvalidUrl.com")!
            )
        }
    }

    @Test("Does not throw for valid init")
    func shouldNotThrowForValidInit() throws {
        _ = try MockPersistentDataContainer(
            storeName: self.expectedStoreName,
            in: .module
        )
    }

    // MARK: - Load tests

    @Test("Load throws when container load fails")
    func loadThrows() async throws {
        let container = MockPersistentDataContainer(containerLoadError: MockError.mock)
        await #expect(throws: (any Error).self) {
            try await container.load()
        }
    }

    @Test("Load succeeds with valid container")
    func loadSucceeds() async throws {
        let container = try MockPersistentDataContainer(
            storeName: self.expectedStoreName,
            in: .module
        )
        try await container.load()
    }

    // MARK: - File protection level tests

    #if !os(macOS)
    @Test("Configure file protection type adds a store description")
    func setFileProtectionType() throws {
        let coreDataContainer = MockCoreDataContainer(
            containerLoadError: nil,
            persistentStoreDescriptions: []
        )
        let container = MockPersistentDataContainer(container: coreDataContainer)
        container.configure(fileProtectionType: .complete)
        #expect(coreDataContainer.persistentStoreDescriptions.count == 1)
    }
    #endif
}
