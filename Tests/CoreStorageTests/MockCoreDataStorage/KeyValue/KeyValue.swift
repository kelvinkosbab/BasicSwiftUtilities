//
//  KeyValue.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData
import CoreStorage

// MARK: - KeyValue

//public struct KeyValue: ObjectIdentifiable, AssociatedWithPersistentObject, Hashable {
//    
//    public typealias PersistedObject = KeyValueManagedObject
//    
//    public let identifier: String
//    public let key: String
//    public let value: String
//}

// MARK: - KeyValueManagedObject

//extension KeyValueManagedObject: PersistentObjectIdentifiable, StructConvertable {
//    
//    public var structValue: KeyValue? {
//        get {
//            
//            guard let identifier = self.identifier, let value = self.value else {
//                return nil
//            }
//            
//            return KeyValue(
//                identifier: identifier,
//                key: identifier,
//                value: value
//            )
//        }
//        set {
//            self.identifier = newValue?.identifier
//            self.value = newValue?.value
//        }
//    }
//}

// MARK: - PersistentDataContainer

//struct MockDataModelContainer
