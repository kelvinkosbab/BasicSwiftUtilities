//
//  ToastContent.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import SwiftUI

// MARK: - ToastContent

/// Defines content supported content for a toast.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ToastContent {
    
    /// Primary title message.
    let title: String
    
    /// Optional description. This text will be displayed directly below the title.
    let description: String?
    
    /// Optional image and optional tint color displayed on tthe leading edge of the toast.
    let leadingImage: (image: Image, tintColor: Color?)?

    /// Optional image and optional tint color displayed on tthe trailing edge of the toast.
    let trailingImage: (image: Image, tintColor: Color?)?
    
    /// Constructor.
    ///
    /// - Parameter title: Primary title message.
    /// - Parameter description: Optional description. This text will be displayed directly below the title.
    /// - Parameter leadingImage: Optional image and optional tint color displayed on tthe leading edge of the toast.
    /// - Parameter trailingImage: Optional image and optional tint color displayed on tthe trailing edge of the toast.
    public init(title: String,
                description: String? = nil,
                leadingImage: (image: Image, tintColor: Color?)? = nil,
                trailingImage: (image: Image, tintColor: Color?)? = nil) {
        self.title = title
        self.description = description
        self.leadingImage = leadingImage
        self.trailingImage = trailingImage
    }
}
