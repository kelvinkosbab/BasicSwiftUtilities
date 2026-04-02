//
// Copyright (c) 2023 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// PROPRIETARY/CONFIDENTIAL
//
// Use is subject to license terms.
//

import CoreData
import CoreStorage

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

// MARK: - KeyValueDataContainer

struct KeyValueDataContainer: PersistentDataContainer {

    static let shared = KeyValueDataContainer()

    let coreDataContainer: CoreDataPersistentContainer

    private init() {
        do {
            try self.init(storeName: "KeyValueDataModel", in: .module)
        } catch {
            fatalError("Unable to find 'KeyValueDataModel' CoreData model")
        }
    }

    init(container: CoreDataPersistentContainer) {
        self.coreDataContainer = container
    }
}
