//
//  CodableStoreErrorTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import Foundation
@testable import CoreStorage

// MARK: - Helpers

private let mockCause = NSError(domain: "Test", code: 42, userInfo: nil)

struct ErrorCase: Sendable {
    let error: DiskBackedJSONCodableStoreError
    let expectedSubstring: String
}

let allErrorCases: [ErrorCase] = [
    ErrorCase(error: .fileManagerError(cause: mockCause), expectedSubstring: "FileManagerError"),
    ErrorCase(error: .encodingFailure(cause: mockCause), expectedSubstring: "EncodingFailure"),
    ErrorCase(error: .writeFailure(cause: mockCause), expectedSubstring: "WriteFailure"),
    ErrorCase(error: .readFailure(cause: mockCause), expectedSubstring: "ReadFailure"),
    ErrorCase(error: .decodingFailure(cause: mockCause), expectedSubstring: "DecodingFailure"),
]

// MARK: - DiskBackedJSONCodableStoreError Tests

@Suite("DiskBackedJSONCodableStoreError")
struct DiskBackedJSONCodableStoreErrorTests {

    @Test(
        "Error description contains the case name and the underlying cause",
        arguments: allErrorCases
    )
    func descriptionContainsCaseAndCause(_ testCase: ErrorCase) {
        #expect(testCase.error.description.contains(testCase.expectedSubstring))
        #expect(testCase.error.description.contains("cause"))
    }

    @Test("LocalizedError errorDescription matches description")
    func errorDescriptionMatchesDescription() {
        let error = DiskBackedJSONCodableStoreError.fileManagerError(cause: mockCause)
        #expect(error.errorDescription == error.description)
    }
}

// MARK: - PersistentDataContainerError Tests

@Suite("PersistentDataContainerError")
struct PersistentDataContainerErrorTests {

    @Test("failedToLocateModel description includes store name and .momd extension")
    func failedToLocateModel() {
        let error = PersistentDataContainerError.failedToLocateModel(
            name: "TestModel",
            bundleIdentifier: Bundle.main.bundleIdentifier
        )
        let description = error.errorDescription ?? ""
        #expect(description.contains("TestModel"))
        #expect(description.contains(".momd"))
    }

    @Test("failedToLoadModel description includes the model URL")
    func failedToLoadModel() {
        let url = URL(fileURLWithPath: "/tmp/TestModel.momd")
        let error = PersistentDataContainerError.failedToLoadModel(url: url)
        let description = error.errorDescription ?? ""
        #expect(description.contains("TestModel.momd"))
    }

    @Test("Errors expose a non-nil errorDescription via LocalizedError")
    func conformsToLocalizedError() {
        let error: LocalizedError = PersistentDataContainerError.failedToLocateModel(
            name: "Test",
            bundleIdentifier: Bundle.main.bundleIdentifier
        )
        #expect(error.errorDescription != nil)
    }
}
