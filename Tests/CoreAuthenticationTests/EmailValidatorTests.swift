//
//  EmailValidatorTests.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import XCTest
@testable import CoreAuthentication

// MARK: - EmailValidatorTests

class EmailValidatorTests : XCTestCase {
    
    func testValidEmails() {
        let validator = EmailValidator()
        XCTAssertNoThrow(try validator.validate("email@email.com"))
        XCTAssertNoThrow(try validator.validate("123@123.com"))
    }
    
    func testInvalidEmails() {
        let validator = EmailValidator()
        XCTAssertThrowsError(try validator.validate(""))
        XCTAssertThrowsError(try validator.validate("com"))
        XCTAssertThrowsError(try validator.validate("123"))
        XCTAssertThrowsError(try validator.validate("@email.com"))
        XCTAssertThrowsError(try validator.validate("email.com"))
    }
}
