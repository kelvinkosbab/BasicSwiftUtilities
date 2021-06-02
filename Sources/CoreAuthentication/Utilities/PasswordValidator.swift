//
//  PasswordValidator.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

// MARK: - PasswordValidator

public struct PasswordValidator {
    
    public init() {}
    
    /// Regex to tests the strength of a password.
    ///
    /// Requirements:
    /// - At least one uppercase,
    /// - At least one digit.
    /// - At least one lowercase.
    /// - 8 characters total.
    ///
    /// - More details:
    ///
    /// ^                                           Start anchor
    ///
    /// (?=.*[A-Z].*[A-Z])              Ensure string has two uppercase letters.
    /// (?=.*[A-Z])                          Ensure string has one uppercase letter.
    ///
    /// (?=.*[!@#$&*])                    Ensure string has one special case letter.
    ///
    /// (?=.*[0-9].*[0-9])               Ensure string has two digits.
    /// (?=.*[0-9])                          Ensure string has one digit.
    ///
    /// (?=.*[a-z].*[a-z].*[a-z])    Ensure string has three lowercase letters.
    ///
    /// .{8}                                        Ensure string is of length 8.
    ///
    /// $                                           End anchor.
    private let passwordStrengthRegex = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
    
    
    /// Validates a given password strength.
    ///
    /// Requirements:
    /// - At least one uppercase,
    /// - At least one digit.
    /// - At least one lowercase.
    /// - 8 characters total.
    ///
    /// - Parameter password: The password to validate.
    ///
    /// - Returns: `true` if the password is valid. `false` otherwise.
    public func validate(password: String) -> Bool {
        return self.passwordStrengthRegex.evaluate(with: password)
    }
}
