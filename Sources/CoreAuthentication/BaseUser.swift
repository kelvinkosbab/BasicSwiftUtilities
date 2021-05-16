//
//  BaseUser.swift
//  
//  Copyright © 2020 Kozinga. All rights reserved.
//

import Foundation

// MARK: - User

public struct BaseUser : Hashable {
    
    public let identifier: String
    public let authenticationToken: String
    public let refreshToken: String?
    public let isAnonymous: Bool
    public let email: String?
    public var displayName: String?
    public let isEmailVerified: Bool
    public var photoURL: URL?
    
    public static func == (lhs: BaseUser, rhs: BaseUser) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.authenticationToken == rhs.authenticationToken &&
            lhs.refreshToken == rhs.refreshToken &&
            lhs.isAnonymous == rhs.isAnonymous &&
            lhs.email == rhs.email &&
            lhs.displayName == rhs.displayName &&
            lhs.isEmailVerified == rhs.isEmailVerified &&
            lhs.photoURL == rhs.photoURL
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
    
    public init(identifier: String,
                authenticationToken: String,
                refreshToken: String?,
                isAnonymous: Bool,
                email: String?,
                displayName: String?,
                isEmailVerified: Bool,
                photoURL: URL?) {
        self.identifier = identifier
        self.authenticationToken = authenticationToken
        self.refreshToken = refreshToken
        self.isAnonymous = isAnonymous
        self.email = email
        self.displayName = displayName
        self.isEmailVerified = isEmailVerified
        self.photoURL = photoURL
    }
}
