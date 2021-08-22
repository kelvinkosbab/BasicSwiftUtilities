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
    
    /// Optional image displayed on tthe left side of the toast.
    ///
    /// - Warning: If either `image` or `tintColor` are `nil` no image will be rrendered.
    let image: Image?
    
    /// Optional tint color displayed on tthe left side of the toast.
    ///
    /// - Warning: If either `image` or `tintColor` are `nil` no image will be rrendered.
    let tintColor: Color?
    
    public init(title: String,
                description: String? = nil,
                image: Image? = nil,
                tintColor: Color? = nil) {
        self.title = title
        self.description = description
        self.image = image
        self.tintColor = tintColor
    }
}
