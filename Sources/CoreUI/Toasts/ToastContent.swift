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
@available(iOS 13.0, macOS 12.0, tvOS 13.0, *)
public struct ToastContent {
    
    public enum SubContent : Equatable {
        
        case none
        case image(_ image: Image)
        case tintedImage(_ image: Image, _ tintColor: Color)
        
        @ViewBuilder
        func body() -> some View {
            switch self {
            case .none:
                Rectangle()
                    .fill(.clear)
                
            case .image(let image):
                image
                    .resizable()
                
            case .tintedImage(let image, let tintColor):
                image
                    .resizable()
                    .foregroundColor(tintColor)
            }
        }
        
        public static func == (lhs: SubContent, rhs: SubContent) -> Bool {
            switch lhs {
            case .none:
                switch rhs {
                case .none: return true
                default: return false
                }
            case .image:
                switch rhs {
                case .image: return true
                default: return false
                }
            case .tintedImage:
                switch rhs {
                case .tintedImage: return true
                default: return false
                }
            }
        }
    }
    
    /// Primary title message.
    let title: String
    
    /// Optional description. This text will be displayed directly below the title.
    let description: String?
    
    /// Optional image and optional tint color displayed on tthe leading edge of the toast.
    let leading: SubContent

    /// Optional image and optional tint color displayed on tthe trailing edge of the toast.
    let trailing: SubContent
    
    /// Constructor.
    ///
    /// - Parameter title: Primary title message.
    /// - Parameter description: Optional description. This text will be displayed directly below the title.
    /// Default is `nil`.
    /// - Parameter leadingImage: Optional image and optional tint color displayed on tthe leading edge
    /// of the toast. Default is `.none`.
    /// - Parameter trailingImage: Optional image and optional tint color displayed on tthe trailing edge
    /// of the toast. Default is `.none`.
    public init(
        title: String,
        description: String? = nil,
        leading: ToastContent.SubContent = .none,
        trailing: ToastContent.SubContent = .none
    ) {
        self.title = title
        self.description = description
        self.leading = leading
        self.trailing = trailing
    }
}

#endif
