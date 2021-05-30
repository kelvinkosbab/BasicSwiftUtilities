//
//  Authentication.swift
//
//  Copyright © 2020 Kozinga. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import Core

// MARK: - Authentication

public protocol AuthenticationDelegate : AnyObject {
    func didSignIn(identifier: String)
    func didSignOut()
}

public class Authentication {
    
    public enum Error : Swift.Error, LocalizedError {
        
        case unknownError
        case alreadySignedIn
        case noCurrentUser
        
        public var errorDescription: String? {
            switch self {
            case .unknownError:
                return "Unknown error."
            case .alreadySignedIn:
                return "Already signed in."
            case .noCurrentUser:
                return "No user is currently signed in"
            }
        }
    }
    
    // MARK: - Init / Properties
    
    public weak var delegate: AuthenticationDelegate?
    private let logger: Logger = Logger(category: "Authentication")
    private let firebaseAuthentication: FirebaseAuth.Auth = Auth.auth()
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
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
    
    public var isSignedIn: Bool {
        return self.currentUserIdentifier != nil
    }
    
    public init() {
        self.currentUserIdentifier = self.firebaseAuthentication.currentUser?.uid
        self.authStateDidChangeListenerHandle = self.firebaseAuthentication.addStateDidChangeListener(self.handleAuthStateChange)
    }
    
    deinit {
        if let authStateDidChangeListenerHandle = self.authStateDidChangeListenerHandle {
            self.firebaseAuthentication.removeStateDidChangeListener(authStateDidChangeListenerHandle)
        }
    }
    
    // MARK: - Auth State Change
    
    /// The block is invoked immediately after adding it according to it's standard invocation semantics, asynchronously on the main thread.
    /// Users should pay special attention to making sure the block does not inadvertently retain objects which should not be retained
    /// by the long-lived block. The block itself will be retained by `FIRAuth` until it is unregistered or until the `FIRAuth` instance
    /// is otherwise deallocated.
    private func handleAuthStateChange(firebaseAuth: FirebaseAuth.Auth, firebaseUser: FirebaseAuth.User?) {
        if self.currentUserIdentifier != firebaseUser?.uid {
            self.currentUserIdentifier = firebaseUser?.uid
        }
    }
    
    // MARK: - Sign In / Create Account
    
    /// Creates and, on success, signs in a user with the given email address and password.
    ///
    /// - Parameter email: The user's email address.
    /// - Parameter password: The user's desired password.
    /// - Parameter completion: A block which is invoked when the sign up flow finishes, or is
    /// canceled. Invoked asynchronously on the main thread in the future.
    public func createUser(email: String, password: String, completion: @escaping (CustomResult<BaseUser>) -> Void) {
        
        guard !self.isSignedIn else {
            completion(.failure(Error.alreadySignedIn))
            return
        }
        
        self.firebaseAuthentication.createUser(withEmail: email, password: password) { [weak self] authDataResult, error in
            
            guard let authDataResult = authDataResult else {
                let error = error ?? Error.unknownError
                self?.logger.error("Failed refreshing user: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            self?.reloadUser(from: authDataResult.user, completion: completion)
        }
    }
    
    /// Signs in using an email address and password.
    ///
    /// - Parameter email: The user's email address.
    /// - Parameter password: The user's password.
    /// - Parameter completion: A block which is invoked when the sign in flow finishes, or is
    /// canceled. Invoked asynchronously on the main thread in the future.
    public func signIn(email: String, password: String, completion: @escaping (CustomResult<BaseUser>) -> Void) {
        
        if !self.isSignedIn {
            self.logger.info("User already logged in. Resetting before attempting sign in.")
            try? self.signOut()
        }
        
        self.firebaseAuthentication.signIn(withEmail: email, password: password) { [weak self] authDataResult, error in
            
            guard let authDataResult = authDataResult else {
                let error = error ?? Error.unknownError
                self?.logger.error("Failed refreshing user: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            self?.reloadUser(from: authDataResult.user, completion: completion)
        }
    }
    
    // MARK: - Reload User
    
    public func reloadCurrentUser(completion: @escaping (_ response: CustomResult<BaseUser>) -> Void) {
        
        guard let firebaseUser = self.firebaseAuthentication.currentUser else {
            let error = Authentication.Error.noCurrentUser
            self.logger.error("Failed refreshing user: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        self.reloadUser(from: firebaseUser, completion: completion)
    }
    
    private func reloadUser(from firebaseUser: Firebase.User, completion: @escaping (_ result: CustomResult<BaseUser>) -> Void) {
        firebaseUser.getIDToken { [weak self] authenticationToken, error in
            
            guard let authenticationToken = authenticationToken else {
                let error = error ?? Authentication.Error.unknownError
                self?.logger.error("Failed refreshing user: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            firebaseUser.reload { [weak self] error in
                
                guard let firebaseUser = self?.firebaseAuthentication.currentUser else {
                    let error = error ?? Authentication.Error.unknownError
                    self?.logger.error("Failed refreshing user: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                let user = BaseUser(identifier: firebaseUser.uid,
                                    authenticationToken: authenticationToken,
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
    
    /// Signs out the current user.
    ///
    /// - Throws if there is an error signing out.
    public func signOut() throws {
        
        guard !self.isSignedIn else {
            self.logger.debug("Already signed out.")
            return
        }
        
        do {
            try self.firebaseAuthentication.signOut()
        } catch {
            self.logger.error("Failed to log out: \(error.localizedDescription)")
            throw error
        }
    }
}
