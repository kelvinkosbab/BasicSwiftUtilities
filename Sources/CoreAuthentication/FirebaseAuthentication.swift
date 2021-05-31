//
//  FirebaseAuthentication.swift
//  
//  Copyright © 2020 Kozinga. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import Core

// MARK: - FirebaseAuth

public class FirebaseAuthentication : AuthenticationProvider {
    
    public weak var delegate: AuthenticationDelegate?
    private let firebaseAuth: Firebase.Auth
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private let logger = Logger(category: "FirebaseAuthentication")
    
    public init() {
        self.firebaseAuth = Firebase.Auth.auth()
        self.currentUserIdentifier = self.firebaseAuth.currentUser?.uid
    }
    
    deinit {
        if let authStateDidChangeListenerHandle = self.authStateDidChangeListenerHandle {
            self.firebaseAuth.removeStateDidChangeListener(authStateDidChangeListenerHandle)
        }
    }
    
    // MARK: - AuthenticationProvider
    
    private(set) public var currentUserIdentifier: String? {
        didSet {
            
            guard self.currentUserIdentifier != oldValue else {
                return
            }
            
            if let currentUserIdentifier = self.currentUserIdentifier {
                self.logger.info("User did sign in", privateMessage: currentUserIdentifier)
                self.delegate?.didSignIn(identifier: currentUserIdentifier)
            } else {
                self.logger.info("User did sign out")
                self.delegate?.didSignOut()
            }
        }
    }
    
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
    
    public func signOut(completion: @escaping (Result) -> Void) {
        do {
            try self.firebaseAuth.signOut()
            completion(.success)
        } catch {
            completion(.failure(error))
        }
    }
    
    private func handleAuthStateChange(firebaseAuth: FirebaseAuth.Auth, firebaseUser: FirebaseAuth.User?) {
        if self.currentUserIdentifier != firebaseUser?.uid {
            self.currentUserIdentifier = firebaseUser?.uid
        }
    }
}
