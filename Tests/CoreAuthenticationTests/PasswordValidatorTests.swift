//
//  PasswordValidatorTests.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import XCTest
@testable import CoreAuthentication

// MARK: - PasswordValidatorTests

class PasswordValidatorTests : XCTestCase {
    
    let basicRegexRequirements = "1Aa"
    
    func testValidPasswords() {
        let validator = PasswordValidator()
        XCTAssertNoThrow(try validator.validate("\(self.basicRegexRequirements)bcdce"))
    }
    
    func testInvalidPasswords() {
        let validator = PasswordValidator()
        XCTAssertThrowsError(try validator.validate(""))
        XCTAssertThrowsError(try validator.validate("\(self.basicRegexRequirements)4567"))
        XCTAssertThrowsError(try validator.validate("12345678"))
        XCTAssertThrowsError(try validator.validate("abcdefgh"))
        XCTAssertThrowsError(try validator.validate("\(self.basicRegexRequirements)defg"))
    }
}
