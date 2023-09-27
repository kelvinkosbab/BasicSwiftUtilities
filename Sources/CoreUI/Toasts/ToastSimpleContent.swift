//
//  ToastSimpleContent.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastSimpleContent

/// Determines what kind of content to render in the description under the title of the toast.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
public enum ToastSimpleContent {
    
    /// Description is string.
    case string(String)
    
    /// Description is an image.
    case image(_ image: Image)
    
    /// Description is an image followed by a string.
    case leadingImage(
        _ image: Image,
        description: String
    )
    
    /// Description is a string followed by an image.
    case trailingImage(
        _ image: Image,
        description: String
    )
}

#endif
