//
//  KeyValueManagedObject.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import CoreData

/// NSManagedObject subclass for the KeyValueDataModel entity.
@objc(KeyValueManagedObject)
public class KeyValueManagedObject: NSManagedObject {
    @NSManaged public var identifier: String?
    @NSManaged public var value: String?
}
