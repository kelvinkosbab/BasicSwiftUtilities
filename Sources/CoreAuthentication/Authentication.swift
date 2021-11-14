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
    
    @available(iOS 13.0.0, *)
    public func createUser(email: String,
                           password: String) async -> CustomResult<BaseUser> {
        await withCheckedContinuation { continuation in
            self.createUser(email: email, password: password) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    public func signIn(email: String,
                       password: String,
                       completion: @escaping (CustomResult<BaseUser>) -> Void) {
        self.authenticationProvider.signIn(email: email,
                                           password: password,
                                           completion: completion)
    }
    
    @available(iOS 13.0.0, *)
    public func signIn(email: String,
                       password: String) async -> CustomResult<BaseUser> {
        await withCheckedContinuation { continuation in
            self.signIn(email: email, password: password) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    public func reloadCurrentUser(completion: @escaping (CustomResult<BaseUser>) -> Void) {
        self.authenticationProvider.reloadCurrentUser(completion: completion)
    }
    
    @available(iOS 13.0.0, *)
    public func reloadCurrentUser() async -> CustomResult<BaseUser> {
        await withCheckedContinuation { continuation in
            self.reloadCurrentUser { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    public func signOut(completion: @escaping (Result) -> Void) {
        self.authenticationProvider.signOut(completion: completion)
    }
    
    @available(iOS 13.0.0, *)
    public func signOut() async -> Result {
        await withCheckedContinuation { continuation in
            self.signOut { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    public func sendPasswordReset(email: String, completion: @escaping (Result) -> Void) {
        self.authenticationProvider.sendPasswordReset(email: email, completion: completion)
    }
    
    @available(iOS 13.0.0, *)
    public func sendPasswordReset(email: String) async -> Result {
        await withCheckedContinuation { continuation in
            self.sendPasswordReset(email: email) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
