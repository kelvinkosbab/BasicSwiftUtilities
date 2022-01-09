//
//  Validator.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Validator

/// Object that Validates a value.
public protocol Validator {
    
    associatedtype ValueType
    
    /// Validates a value. Throws if value is not valid.
    ///
    /// - Parameter value: A value to validate.
    ///
    /// - Throws if value is not valid.
    func validate(_ value: ValueType) throws
}

// MARK: - EmailValidator

/// Objects that validates emails.
public struct EmailValidator : Validator {
    
    public enum Error : Swift.Error, LocalizedError {
        case invalidFormat
        
        public var errorDescription: String? {
            switch self {
            case .invalidFormat:
                return "Your email format is invalid."
            }
        }
    }
    
    /// Regex to validate the format of an email address.
    private let emailRegex: NSPredicate
    
    /// Constructs `EmailValidator`.
    ///
    /// - Parameter emailRegex: Regex to validate the format of an email address. Default `emailRegex
    ///  is `"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"`
    public init(emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}") {
        self.emailRegex = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    }
    
    /// Validates the format of an email address.
    ///
    /// - Parameter value: The email to validate.
    ///
    /// - Throws if the email is an invalid format.
    public func validate(_ value: String) throws {
        if !self.emailRegex.evaluate(with: value) {
            throw Error.invalidFormat
        }
    }
}

// MARK: - PasswordValidator

/// Objects that validates passwords.
public struct PasswordValidator : Validator {
    
    public enum Error : Swift.Error, LocalizedError {
        case weakPassword
        
        public var errorDescription: String? {
            switch self {
            case .weakPassword:
                return "Your password is not strong enough. It needs at least one uppercase letter, one numeral digit, one lowercase letters, and be at least 8 characters long."
            }
        }
    }
    
    /// Regex to test the strength of a password.
    ///
    /// - Regex details:
    ///
    /// ^                                           Start anchor
    ///
    /// (?=.*[A-Z].*[A-Z])              Ensure string has two uppercase letters.
    /// (?=.*[A-Z])                           Ensure string has one uppercase letter.
    ///
    /// (?=.*[!@#$&*])                    Ensure string has one special case letter.
    ///
    /// (?=.*[0-9].*[0-9])               Ensure string has two digits.
    /// (?=.*[0-9])                            Ensure string has one digit.
    ///
    /// (?=.*[a-z].*[a-z].*[a-z])      Ensure string has three lowercase letters.
    ///
    /// .{8}                                        Ensure string is of length 8.
    ///
    /// $                                           End anchor.
    private let passwordStrengthRegex: NSPredicate
    
    /// Constructs `PasswordValidator`.
    ///
    /// - Parameter passwordStrengthRegex: Regex to test the strength of a password. Default `passwordStrengthRegex`
    /// is `"(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}"`.
    ///
    /// - Note: Default password requirements: At least one uppercase, at least one numerical digit, at least one lowercase, 8 characters total.
    public init(passwordStrengthRegex: String = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}") {
        self.passwordStrengthRegex = NSPredicate(format: "SELF MATCHES %@", passwordStrengthRegex)
    }
    
    /// Validates a given password strength.
    ///
    /// - Parameter value: The password to validate.
    ///
    /// - Throws if password is not strong enough.
    public func validate(_ value: String) throws {
        if !self.passwordStrengthRegex.evaluate(with: value) {
            throw Error.weakPassword
        }
    }
}
