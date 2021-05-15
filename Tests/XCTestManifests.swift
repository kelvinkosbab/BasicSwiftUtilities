//
//  XCTestManifests.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CoreTests.allTests),
        testCase(CoreUITests.allTests),
    ]
}
#endif

