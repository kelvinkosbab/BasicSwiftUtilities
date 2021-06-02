//
//  EmailValidator.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

// MARK: - EmailValidator

public struct EmailValidator {
    
    public init() {}
    
    /// Regex to validate the format of an email address.
    private let emailStrengthRegex = NSPredicate(format:"SELF MATCHES %@",
                                                 "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    
    /// Validates the format of a given email.
    ///
    /// - Parameter email: The email to validate.
    ///
    /// - Returns: `true` if the email is valid. `false` otherwise.
    public func validate(email: String) -> Bool {
        return emailStrengthRegex.evaluate(with: email)
    }
}
