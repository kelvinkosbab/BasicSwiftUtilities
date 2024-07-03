//
//  QueryExecutorTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(tvOS)

import XCTest
import HealthKit
@testable import CoreHealth

// MARK: - Mocks

class MockQueryExecutor: QueryExecutor {

    var query: HKQuery?

    func execute(_ query: HKQuery) {
        self.query = query
    }
}

// MARK: - QueryExecutorTests

@available(iOS 13.0, watchOS 8.0, *)
class QueryExecutorTests: XCTestCase {

    let queryOptionStartDate = Date()
    let queryOptionsEndDate = Date()

    var queryOptions: QueryOptions {
        return QueryOptions(
            startDate: self.queryOptionStartDate,
            endDate: self.queryOptionsEndDate
        )
    }

    func testQuerySampleTypeWithCompletionCallsHKExecute() {
    }

    func testQuerySampleTypeCallsHKExecute() async {

    }

    func testQueryIdentifierWithCompletionCallsHKExecute() {
        let expectation = expectation(description: #function)
        let healthKitIdentifier: HKQuantityTypeIdentifier = .bodyTemperature
        let mock = MockQueryExecutor()
        mock.query(
            identifier: healthKitIdentifier,
            unit: Length.meters,
            options: self.queryOptions
        ) { result in
            switch result {
            case .error:
                // do something
                break
            case .success:
                // do something
                break
            }
        }
        wait(for: [expectation], timeout: 5)
    }

    func testQueryIdentifierCallsHKExecute() async {
        do {
            let healthKitIdentifier: HKQuantityTypeIdentifier = .bodyTemperature
            let mock = MockQueryExecutor()
            _ = try await mock.query(
                identifier: healthKitIdentifier,
                unit: Length.meters,
                options: self.queryOptions
            )
            XCTAssert(mock.query != nil)
        } catch {
            XCTFail("Test threw error: \(error)")
        }
    }
}

#endif
