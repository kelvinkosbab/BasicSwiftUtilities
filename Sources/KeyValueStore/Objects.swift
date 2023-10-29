//
//  Objects.swift
//
//  Copyright © Kozinga. All rights reserved.
//

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
