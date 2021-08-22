//
//  AlertContent.swift
//
//  Created by Kelvin Kosbab on 8/16/21.
//

import SwiftUI

// MARK: - AlertContent

/// Defines content supported content for a toast.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AlertContent {
    
    public struct Action {
        let title: String
        let isDestructive: Bool
        let action: () -> Void
    }
    
    /// Primary title message.
    let title: String
    
    /// Message of the alert.
    let message: String
    
    /// Primary action
    let primaryAction: Action
    
    /// Secondary action
    let secondaryAction: Action?
    
    public init(title: String,
                message: String,
                primaryAction: Action,
                secondaryAction: Action?) {
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}
