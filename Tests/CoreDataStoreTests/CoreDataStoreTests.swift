//
//  CoreDataStoreTests.swift
//
//  Copyright © 2021 Kozinga. All rights reserved.
//

import XCTest
@testable import CoreDataStore

final class MockObject: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var identifier: String?
}

// https://dmytro-anokhin.medium.com/core-data-and-swift-package-manager-6ed9ff70921a
final class CoreDataStoreTests: XCTestCase {
    
    func setUp() {
        let modelDescription = CoreDataModelDescription(
            entities: [
                .entity(
                    name: "MockObject",
                    managedObjectClass: MockObject.self,
                    attributes: [
                        .attribute(name: "name", type: .stringAttributeType)
                        .attribute(name: "identifier", type: .stringAttributeType)
                    ],
                    relationships: []),
            ]
        )

        let model = modelDescription.makeMode()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(true, true)
    }
}
