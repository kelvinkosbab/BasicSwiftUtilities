//
//  QueryExecutorTests.swift
//
//  Created by Kelvin Kosbab on 10/1/22.
//

import XCTest
import HealthKit
@testable import HealthKitHelpers

// MARK: - Mocks

class MockQueryExecutor : QueryExecutor {
    
    var query: HKQuery?
    
    func execute(_ query: HKQuery) {
        self.query = query
    }
}

// MARK: - QueryExecutorTests

class QueryExecutorTests : XCTestCase {
    
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
            case .error(let error):
                // do something
                break
            case .success(samples: let samples):
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
                options: self.queryOptions)
            XCTAssert(mock.query != nil)
        } catch {
            XCTFail("Test threw error: \(error)")
        }
    }
}
