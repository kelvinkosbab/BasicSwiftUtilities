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
        let error = self.containerLoadError
        Task { @MainActor in
            block(description, error)
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

    @Test("Does not throw for valid init with programmatic model")
    func shouldNotThrowForValidInit() throws {
        let model = makeKeyValueManagedObjectModel()
        let container = MockPersistentDataContainer(
            storeName: self.expectedStoreName,
            managedObjectModel: model
        )
        #expect(container.coreDataContainer.viewContext.concurrencyType == .mainQueueConcurrencyType)
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
        let model = makeKeyValueManagedObjectModel()
        let container = MockPersistentDataContainer(
            storeName: self.expectedStoreName,
            managedObjectModel: model
        )
        // Use in-memory store so no disk access is needed
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.coreDataContainer.persistentStoreDescriptions = [description]
        try await container.load()
    }

    // MARK: - File protection level tests

    #if !os(macOS)
    @Test("Configure file protection type sets option on existing store descriptions")
    func setFileProtectionType() throws {
        let existingDescription = NSPersistentStoreDescription()
        let coreDataContainer = MockCoreDataContainer(
            containerLoadError: nil,
            persistentStoreDescriptions: [existingDescription]
        )
        let container = MockPersistentDataContainer(container: coreDataContainer)
        container.configure(fileProtectionType: .complete)

        // Expect no duplicate description was appended.
        #expect(coreDataContainer.persistentStoreDescriptions.count == 1)
        // Expect the protection option was set on the existing description.
        let value = existingDescription.options[NSPersistentStoreFileProtectionKey] as? FileProtectionType
        #expect(value == .complete)
    }
    #endif
}
