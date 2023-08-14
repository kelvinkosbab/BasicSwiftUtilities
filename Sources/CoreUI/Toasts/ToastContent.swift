//
//  ToastContent.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import Foundation
import SwiftUI

// MARK: - ToastContent

/// Defines content supported content for a toast.
@available(iOS 13.0, macOS 12.0, tvOS 15.0, *)
public struct ToastContent {
    
    /// Primary title message.
    let title: String
    
    /// Optional description. This view will be displayed directly below the title.
    let description: ToastDescriptionView.ContentType?
    
    /// Optional image and optional tint color displayed on tthe leading edge of the toast.
    let leading: ToastImageContent

    /// Optional image and optional tint color displayed on tthe trailing edge of the toast.
    let trailing: ToastImageContent
    
    /// Constructor.
    ///
    /// - Parameter title: Primary title message.
    /// - Parameter description: Optional description. This view will be displayed directly below the title.
    /// Default is `nil`.
    /// - Parameter leadingImage: Optional image and optional tint color displayed on tthe leading edge
    /// of the toast. Default is `.none`.
    /// - Parameter trailingImage: Optional image and optional tint color displayed on tthe trailing edge
    /// of the toast. Default is `.none`.
    public init(
        title: String,
        description: ToastDescriptionView.ContentType? = nil,
        leading: ToastImageContent = .none,
        trailing: ToastImageContent = .none
    ) {
        self.title = title
        self.description = description
        self.leading = leading
        self.trailing = trailing
    }
}

#endif
