//
//  Authentication.swift
//
//  Copyright © 2020 Kozinga. All rights reserved.
//

import Foundation
import Core

// MARK: - Authentication

public protocol AuthenticationDelegate : AnyObject {
    func didSignIn(identifier: String)
    func didSignOut()
}

public class Authentication : AuthenticationProvider {
    
    public enum Error : Swift.Error, LocalizedError {
        
        case unknownError
        case noCurrentUser
        
        public var errorDescription: String? {
            switch self {
            case .unknownError:
                return "Unknown error."
            case .noCurrentUser:
                return "No user is currently signed in"
            }
        }
    }
    
    private let authenticationProvider: AuthenticationProvider
    
    public init(authenticationProvider: AuthenticationProvider = FirebaseAuthentication()) {
        self.authenticationProvider = authenticationProvider
    }
    
    // MARK: - AuthenticationProvider
    
    public weak var delegate: AuthenticationDelegate? {
        get {
            return self.authenticationProvider.delegate
        }
        set {
            self.authenticationProvider.delegate = newValue
        }
    }
    
    /// Identifier of the current signed in user.
    public var currentUserIdentifier: String? {
        return self.authenticationProvider.currentUserIdentifier
    }
    
    public func createUser(email: String,
                           password: String,
                           completion: @escaping (CustomResult<BaseUser>) -> Void) {
        self.authenticationProvider.createUser(email: email,
                                               password: password,
                                               completion: completion)
    }
    
    public func signIn(email: String,
                       password: String,
                       completion: @escaping (CustomResult<BaseUser>) -> Void) {
        self.authenticationProvider.signIn(email: email,
                                           password: password,
                                           completion: completion)
    }
    
    public func reloadCurrentUser(completion: @escaping (CustomResult<BaseUser>) -> Void) {
        self.authenticationProvider.reloadCurrentUser(completion: completion)
    }
    
    public func signOut(completion: @escaping (Result) -> Void) {
        self.authenticationProvider.signOut(completion: completion)
    }
    
    public func sendPasswordReset(email: String, completion: @escaping (Result) -> Void) {
        self.authenticationProvider.sendPasswordReset(email: email, completion: completion)
    }
}
