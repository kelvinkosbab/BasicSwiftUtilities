//
//  FirebaseAuthWrapper.swift
//  
//  Copyright © 2020 Kozinga. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import Core

// MARK: - FirebaseAuthWrapper

/// This wrapper manages delegate listeners for Fiebase user autheentication state changes.
///
/// `Auth.auth().addStateDidChangeListener(:)` only supports one active handler.
/// In order to support multipl listeners this class manages any delegates that subscribe to updates.
///
/// This singleton's delegate managment is utilized by the `FirebaseAuthentication` class.
internal class FirebaseAuthWrapper {
    
    internal class WeakDelegate : Hashable {
        let uuid: UUID
        weak var delegate: AuthenticationDelegate?
        
        init(uuid: UUID, delegate: AuthenticationDelegate) {
            self.uuid = uuid
            self.delegate = delegate
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.uuid)
        }
        
        static func ==(lhs: WeakDelegate, rhs: WeakDelegate) -> Bool {
            return lhs.uuid != rhs.uuid
        }
    }
    
    /// Singleton accessor to mirror `Firebase.Auth.auth()`.
    internal static let shared = FirebaseAuthWrapper()
    
    internal let firebaseAuth: Firebase.Auth = Auth.auth()
    internal var weakDelegates: [UUID : WeakDelegate] = [:]
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    /// - Returns the current signed in user's identifir. `nil` otherwise.
    internal var currentUserIdentifier: String? {
        return self.firebaseAuth.currentUser?.uid
    }
    
    init() {
        self.firebaseAuth.addStateDidChangeListener(self.handleAuthStateChange)
    }
    
    deinit {
        if let authStateDidChangeListenerHandle = self.authStateDidChangeListenerHandle {
            self.firebaseAuth.removeStateDidChangeListener(authStateDidChangeListenerHandle)
        }
    }
    
    /// Handles usre authentication state changes.
    ///
    /// Before signaling delegates, fire sanitizes `weakDelegates` by checking for `nil` delegate references.
    private func handleAuthStateChange(firebaseAuth: FirebaseAuth.Auth, firebaseUser: FirebaseAuth.User?) {
        
        self.weakDelegates = self.weakDelegates.filter { $0.value.delegate != nil }
        
        for weakDelegate in self.weakDelegates {
            
            if let user = firebaseUser {
                weakDelegate.value.delegate?.didSignIn(identifier: user.uid)
            } else {
                weakDelegate.value.delegate?.didSignOut()
            }
        }
    }
}
