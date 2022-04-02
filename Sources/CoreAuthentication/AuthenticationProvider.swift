//
//  AuthenticationProvider.swift
//  
//  Copyright © Kozinga. All rights reserved.
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
    
    /// Initiates a password reset for the given email address.
    ///
    /// - Parameter email: The email address of the user.
    /// - Parameter compleetion: Optionally; a block which is invoked when the request finishes. Invoked asynchronously on the main thread in the future.
    func sendPasswordReset(email: String, completion: @escaping (Result) -> Void)
}

public extension AuthenticationProvider {
    
    /// Whether or not a user is signed in.
    ///
    /// - Returns `true` if a user is currently signed in. `false` otherwise.
    var isSignedIn: Bool {
        return self.currentUserIdentifier != nil
    }
    
    /// Creates and, on success, signs in a user with the given email address and password.
    ///
    /// - Parameter email: The user's email address.
    /// - Parameter password: The user's desired password.
    ///
    /// - Throws if there is an error when creating a user.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func createUser(email: String, password: String) async throws -> BaseUser {
        try await withCheckedThrowingContinuation { continuation in
            self.createUser(email: email, password: password) { result in
                switch result {
                case .success(let user):
                    continuation.resume(returning: user)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Signs in using an email address and password.
    ///
    /// - Parameter email: The user's email address.
    /// - Parameter password: The user's password.
    ///
    /// - Throws if there is an error when signing in.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func signIn(email: String, password: String) async throws -> BaseUser {
        try await withCheckedThrowingContinuation { continuation in
            self.signIn(email: email, password: password) { result in
                switch result {
                case .success(let user):
                    continuation.resume(returning: user)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Reloads the currently signed in user's profile.
    ///
    /// - Throws if there is an error when reloading the current user.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func reloadCurrentUser() async throws -> BaseUser {
        try await withCheckedThrowingContinuation { continuation in
            self.reloadCurrentUser() { result in
                switch result {
                case .success(let user):
                    continuation.resume(returning: user)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Signs out the current user.
    ///
    /// - Throws if there is an error when signing out.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func signOut() async throws {
        try await withCheckedThrowingVoidContinuation { continuation in
            self.signOut { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Initiates a password reset for the given email address.
    ///
    /// - Parameter email: The email address of the user.
    ///
    /// - Throws if there is an error when sending the password reset email..
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func sendPasswordReset(email: String) async throws {
        try await withCheckedThrowingVoidContinuation { continuation in
            self.sendPasswordReset(email: email) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
