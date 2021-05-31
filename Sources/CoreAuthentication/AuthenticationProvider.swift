//
//  AuthenticationProvider.swift
//  
//  Copyright © 2020 Kozinga. All rights reserved.
//

import Foundation
import Core

// MARK: - AuthenticationProvider

public protocol AuthenticationProvider : AnyObject {
    
    /// Delegate for providing authentication state hooks.
    var delegate: AuthenticationDelegate? { get set }
    
    /// Current signed in user identifier.
    ///
    /// - Returns the current identifier.
    var currentUserIdentifier: String? { get }
    
    /// Creates and, on success, signs in a user with the given email address and password.
    ///
    /// - Parameter email: The user's email address.
    /// - Parameter password: The user's desired password.
    /// - Parameter completion: A block which is invoked when the sign up flow finishes, or is
    /// canceled. Invoked asynchronously on the main thread in the future.
    func createUser(email: String, password: String, completion: @escaping (CustomResult<BaseUser>) -> Void)
    
    /// Signs in using an email address and password.
    ///
    /// - Parameter email: The user's email address.
    /// - Parameter password: The user's password.
    /// - Parameter completion: A block which is invoked when the sign in flow finishes, or is
    /// canceled. Invoked asynchronously on the main thread in the future.
    func signIn(email: String, password: String, completion: @escaping (CustomResult<BaseUser>) -> Void)
    
    /// Reloads the currently signed in user's profile.
    ///
    /// - Parameter completion: A block which is invoked when the sign in flow finishes, or is
    /// canceled. Invoked asynchronously on the main thread in the future.
    func reloadCurrentUser(completion: @escaping (CustomResult<BaseUser>) -> Void)
    
    /// Signs out the current user.
    ///
    /// - Throws if there is an error signing out.
    func signOut(completion: @escaping (Result) -> Void)
}

public extension AuthenticationProvider {
    
    /// Whether or not a user is signed in.
    ///
    /// - Returns `true` if a user is currently signed in. `false` otherwise.
    var isSignedIn: Bool {
        return self.currentUserIdentifier != nil
    }
}
