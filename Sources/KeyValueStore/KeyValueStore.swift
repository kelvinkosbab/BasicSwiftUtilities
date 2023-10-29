//
//  KeyValueStore.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData
import CoreStorage

// MARK: - KeyValueDataContainer

class KeyValueDataContainer : PersistentDataContainer {
    
    static let shared = KeyValueDataContainer()
    
    let persistentContainer: NSPersistentContainer
    
    convenience init() {
        try! self.init(storeName: "KeyValueModel", in: .module)
    }
    
    required init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }
}

// MARK: - KeyValueStore

public struct KeyValueStore : ObjectStore {
    public typealias Object = KeyValue
    public let context: NSManagedObjectContext
}

public extension KeyValueStore {
    
    static func configure() async throws {
        try await KeyValueDataContainer.shared.load()
    }
    
    init() {
        self.init(container: KeyValueDataContainer.shared)
    }
    
    internal init(container: PersistentDataContainer) {
        self.context = container.persistentContainer.viewContext
    }
    
    func set(
        value: String,
        forKey key: String
    ) throws {
        let object = KeyValue(identifier: key, value: value)
        try self.createOrUpdate(object)
    }
    
    func removeValue(
        forKey key: String
    ) async throws {
        try await self.deleteOne(id: key)
    }
    
    func getValue(
        forKey key: String
    ) async throws -> String? {
        let object = try await self.fetchOne(id: key)
        return object?.value
    }
}

// MARK: - Observer

public class KeyValueObserver : ObservableObject, DataObserverDelegate {
    
    @Published var value: String?
    
    private let observer: DataObserver<KeyValueObserver>
    
    public convenience init(key: String) {
        self.init(
            key: key,
            container: KeyValueDataContainer.shared
        )
    }
    
    internal init(
        key: String,
        container: PersistentDataContainer
    ) {
        let dataStore = KeyValueStore()
        self.observer = dataStore.newObserver(id: key)
        self.observer.delegate = self
    }
    
    public func didAdd(object: KeyValue) {
        self.value = object.value
    }
    
    public func didUpdate(object: KeyValue) {
        self.value = object.value
    }
    
    public func didRemove(object: KeyValue) {
        self.value = nil
    }
}
