//
//  CodableStoreErrorTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import Foundation
@testable import CoreStorage

// MARK: - DiskBackedJSONCodableStoreError Tests

@Suite("DiskBackedJSONCodableStoreError")
struct DiskBackedJSONCodableStoreErrorTests {

    private let cause = NSError(domain: "Test", code: 42, userInfo: nil)

    @Test("fileManagerError description")
    func fileManagerErrorDescription() {
        let error = DiskBackedJSONCodableStoreError.fileManagerError(cause: cause)
        #expect(error.description.contains("FileManagerError"))
    }

    @Test("encodingFailure description")
    func encodingFailureDescription() {
        let error = DiskBackedJSONCodableStoreError.encodingFailure(cause: cause)
        #expect(error.description.contains("EncodingFailure"))
    }

    @Test("writeFailure description")
    func writeFailureDescription() {
        let error = DiskBackedJSONCodableStoreError.writeFailure(cause: cause)
        #expect(error.description.contains("WriteFailure"))
    }

    @Test("readFailure description")
    func readFailureDescription() {
        let error = DiskBackedJSONCodableStoreError.readFailure(cause: cause)
        #expect(error.description.contains("ReadFailure"))
    }

    @Test("decodingFailure description")
    func decodingFailureDescription() {
        let error = DiskBackedJSONCodableStoreError.decodingFailure(cause: cause)
        #expect(error.description.contains("DecodingFailure"))
    }

    @Test("All error cases include cause in description")
    func allCasesIncludeCause() {
        let errors: [DiskBackedJSONCodableStoreError] = [
            .fileManagerError(cause: cause),
            .encodingFailure(cause: cause),
            .writeFailure(cause: cause),
            .readFailure(cause: cause),
            .decodingFailure(cause: cause)
        ]
        for error in errors {
            #expect(error.description.contains("cause"))
        }
    }
}

// MARK: - PersistentDataContainerError Tests

@Suite("PersistentDataContainerError")
struct PersistentDataContainerErrorTests {

    @Test("failedToLocateModel includes name and bundle")
    func failedToLocateModel() {
        let error = PersistentDataContainerError.failedToLocateModel(
            name: "TestModel",
            bundleIdentifier: Bundle.main.bundleIdentifier
        )
        let description = error.errorDescription ?? ""
        #expect(description.contains("TestModel"))
        #expect(description.contains(".momd"))
    }

    @Test("failedToLoadModel includes URL")
    func failedToLoadModel() {
        let url = URL(fileURLWithPath: "/tmp/TestModel.momd")
        let error = PersistentDataContainerError.failedToLoadModel(url: url)
        let description = error.errorDescription ?? ""
        #expect(description.contains("TestModel.momd"))
    }

    @Test("Errors conform to LocalizedError")
    func conformsToLocalizedError() {
        let error: LocalizedError = PersistentDataContainerError.failedToLocateModel(
            name: "Test",
            bundleIdentifier: Bundle.main.bundleIdentifier
        )
        #expect(error.errorDescription != nil)
    }
}
