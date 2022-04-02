//
//  FirebaseAuthentication.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import Core

/// Manages the Firebase authentication client and conforms the API to
/// CoreAuthentication's `AuthenticationProvider` protocol.
///
/// Relies on `FirebaseAuthWrapper` to register and deregister authntication state
/// change delegates due to `Firebase.Auth.auth()`'s limitation of only allowing one
/// state change handler at a time.
public class FirebaseAuthentication : AuthenticationProvider {
    
    private let uuid: UUID
    private let firebase: FirebaseAuthWrapper
    private let logger = Logger(subsystem: "CoreAuthentication.FirebaseAuthentication", category: "FirebaseAuthentication")
    
    private var firebaseAuth: Firebase.Auth {
        return self.firebase.firebaseAuth
    }
    
    public init() {
        self.uuid = UUID()
        self.firebase = FirebaseAuthWrapper.shared
    }
    
    // MARK: - AuthenticationProvider
    
    public weak var delegate: AuthenticationDelegate? {
        get {
            return self.firebase.weakDelegates[self.uuid]?.delegate
        }
        set {
            if let newValue = newValue {
                let weakDelegate = FirebaseAuthWrapper.WeakDelegate(uuid: self.uuid, delegate: newValue)
                self.firebase.weakDelegates[self.uuid] = weakDelegate
            } else {
                self.firebase.weakDelegates.removeValue(forKey: self.uuid)
            }
        }
    }
    
    public var currentUserIdentifier: String? {
        return self.firebaseAuth.currentUser?.uid
    }
    
    // MARK: - Create User
    
    public func createUser(email: String,
                           password: String,
                           completion: @escaping (CustomResult<BaseUser>) -> Void) {
        self.firebaseAuth.createUser(withEmail: email, password: password) { authDataResult, error in
            
            guard let authDataResult = authDataResult else {
                let error = error ?? Authentication.Error.unknownError
                completion(.failure(error))
                return
            }
            
            let firebaseUser = authDataResult.user
            let user = BaseUser(identifier: firebaseUser.uid,
                                refreshToken: firebaseUser.refreshToken,
                                isAnonymous: firebaseUser.isAnonymous,
                                email: firebaseUser.email,
                                displayName: firebaseUser.displayName,
                                isEmailVerified: firebaseUser.isEmailVerified,
                                photoURL: firebaseUser.photoURL)
            
            completion(.success(user))
        }
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
    
    // MARK: - Sign In
    
    public func signIn(email: String,
                       password: String,
                       completion: @escaping (CustomResult<BaseUser>) -> Void) {
        self.firebaseAuth.signIn(withEmail: email, password: password) { authDataResult, error in
            
            guard let authDataResult = authDataResult else {
                let error = error ?? Authentication.Error.unknownError
                completion(.failure(error))
                return
            }
            
            let firebaseUser = authDataResult.user
            let user = BaseUser(identifier: firebaseUser.uid,
                                refreshToken: firebaseUser.refreshToken,
                                isAnonymous: firebaseUser.isAnonymous,
                                email: firebaseUser.email,
                                displayName: firebaseUser.displayName,
                                isEmailVerified: firebaseUser.isEmailVerified,
                                photoURL: firebaseUser.photoURL)
            
            completion(.success(user))
        }
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
    
    // MARK: - Reload Current User
    
    public func reloadCurrentUser(completion: @escaping (CustomResult<BaseUser>) -> Void) {
        
        guard let firebaseUser = self.firebaseAuth.currentUser else {
            completion(.failure(Authentication.Error.noCurrentUser))
            return
        }
        
        firebaseUser.getIDToken { authenticationToken, error in
            
            guard let _ = authenticationToken else {
                let error = error ?? Authentication.Error.unknownError
                completion(.failure(error))
                return
            }
            
            firebaseUser.reload { error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let user = BaseUser(identifier: firebaseUser.uid,
                                    refreshToken: firebaseUser.refreshToken,
                                    isAnonymous: firebaseUser.isAnonymous,
                                    email: firebaseUser.email,
                                    displayName: firebaseUser.displayName,
                                    isEmailVerified: firebaseUser.isEmailVerified,
                                    photoURL: firebaseUser.photoURL)
                
                completion(.success(user))
            }
        }
    }
    
    // MARK: - Sign Oout
    
    public func signOut(completion: @escaping (Result) -> Void) {
        do {
            try self.firebaseAuth.signOut()
            completion(.success)
        } catch {
            completion(.failure(error))
        }
    }
    
    @available(iOS 13.0.0, *)
    public func signOut() async throws {
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
    
    // MARK: - Password Reset
    
    /// Initiates a password reset for the given email address.
    ///
    /// Possible error codes:
    /// - `FIRAuthErrorCodeInvalidRecipientEmail` - Indicates an invalid recipient email was sent in the request.
    /// - `FIRAuthErrorCodeInvalidSender` - Indicates an invalid sender email is set in the console for this action.
    /// - `FIRAuthErrorCodeInvalidMessagePayload` - Indicates an invalid email template for sending update email.
    ///
    /// - Parameter email: The email address of the user.
    /// - Parameter compleetion: Optionally; a block which is invoked when the request finishes. Invoked asynchronously on the main thread in the future.
    public func sendPasswordReset(email: String, completion: @escaping (Result) -> Void) {
        self.firebaseAuth.sendPasswordReset(withEmail: email) { error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success)
        }
    }
    
    @available(iOS 13.0.0, *)
    public func sendPasswordReset(email: String) async throws {
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
