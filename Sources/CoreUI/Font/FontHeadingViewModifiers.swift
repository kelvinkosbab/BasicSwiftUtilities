//
//  FontHeadingViewModifiers.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// MARK: - Heading ViewModifiers

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct HeadingModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.heading,
                weight: .regular,
                design: .default
            ))
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct HeadingBoldModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.heading,
                weight: .bold,
                design: .default
            ))
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct HeadingItalicModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.heading,
                weight: .regular,
                design: .default
            )
                .italic()
            )
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 7.0, *)
private struct HeadingMonospaceModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.heading,
                weight: .regular,
                design: .monospaced
            ))
    }
}

// MARK: - View Extensions

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// Styles a `Text` or `Button` with a regular style and a heading font size.
    func headingStyle() -> some View {
        self.modifier(HeadingModifier())
    }
    
    /// Styles a `Text` or `Button` with a bold style and a heading font size.
    func headingBoldStyle() -> some View {
        self.modifier(HeadingBoldModifier())
    }
    
    /// Styles a `Text` or `Button` with an italic style and a heading font size.
    func headingItalicStyle() -> some View {
        self.modifier(HeadingItalicModifier())
    }
    
    /// Styles a `Text` or `Button` with a monospace style and a heading font size.
    @available(watchOS 7.0, *)
    func headingMonospaceStyle() -> some View {
        self.modifier(HeadingMonospaceModifier())
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12.0, tvOS 16.0, watchOS 6.0, *)
struct HeadingFont_Previews: PreviewProvider {
    
    static let mockString = "This is a string"
    
    static var previews: some View {
        VStack(spacing: 16) {
            Text(self.mockString)
                .headingStyle()
            Text(self.mockString)
                .headingBoldStyle()
            Text(self.mockString)
                .headingItalicStyle()
            Text(self.mockString)
                .headingMonospaceStyle()
        }
        .previewDisplayName("Styled Text(_:)")
        
        VStack(spacing: 16) {
            Button(self.mockString) {}
                .headingStyle()
            Button(self.mockString) {}
                .headingBoldStyle()
            Button(self.mockString) {}
                .headingItalicStyle()
            Button(self.mockString) {}
                .headingMonospaceStyle()
        }
        .previewDisplayName("Styled Button(_:)")
    }
}

#endif
