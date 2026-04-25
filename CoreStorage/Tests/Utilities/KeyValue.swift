//
//  KeyValue.swift
//
//  Copyright © Kozinga. All rights reserved.
//

public import CoreData
@testable public import CoreStorage

// MARK: - KeyValue

public struct KeyValue: ObjectIdentifiable, AssociatedWithPersistentObject, Hashable {

    public typealias PersistentObject = KeyValueManagedObject

    public let identifier: String
    public let value: String

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}

// MARK: - KeyValueManagedObject

extension KeyValueManagedObject: PersistentObjectIdentifiable, StructConvertable {

    public var structValue: KeyValue? {
        get {

            guard let identifier = self.identifier, let value = self.value else {
                return nil
            }

            return KeyValue(
                identifier: identifier,
                value: value
            )
        }
        set {
            self.identifier = newValue?.identifier
            self.value = newValue?.value
        }
    }
}

// MARK: - KeyValueManagedObjectModel

/// Builds the `NSManagedObjectModel` for `KeyValueManagedObject` programmatically.
///
/// SPM cannot compile `.xcdatamodeld` files into `.momd` bundles, so the model
/// must be constructed in code for tests to work with `swift test`.
func makeKeyValueManagedObjectModel() -> NSManagedObjectModel {
    let identifierAttribute = NSAttributeDescription()
    identifierAttribute.name = "identifier"
    identifierAttribute.attributeType = .stringAttributeType
    identifierAttribute.isOptional = true

    let valueAttribute = NSAttributeDescription()
    valueAttribute.name = "value"
    valueAttribute.attributeType = .stringAttributeType
    valueAttribute.isOptional = true

    let entity = NSEntityDescription()
    entity.name = "KeyValueManagedObject"
    entity.managedObjectClassName = "KeyValueManagedObject"
    entity.properties = [identifierAttribute, valueAttribute]

    let model = NSManagedObjectModel()
    model.entities = [entity]
    return model
}

// MARK: - KeyValueDataContainer

struct KeyValueDataContainer: PersistentDataContainer {

    let coreDataContainer: CoreDataPersistentContainer

    /// Creates a fresh container backed by an in-memory store. Each call returns a new
    /// container so tests can run in parallel without sharing state.
    init() {
        let model = makeKeyValueManagedObjectModel()
        let container = NSPersistentContainer(
            name: "KeyValueDataModel",
            managedObjectModel: model
        )
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.coreDataContainer = container
    }

    init(container: CoreDataPersistentContainer) {
        self.coreDataContainer = container
    }
}
