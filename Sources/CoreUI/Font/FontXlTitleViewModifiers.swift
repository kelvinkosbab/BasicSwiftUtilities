//
//  FontXlTitleViewModifiers.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// MARK: - XL Title ViewModifiers

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct XlTitleModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.xlTitle,
                weight: .regular,
                design: .default
            ))
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct XlTitleBoldModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.xlTitle,
                weight: .bold,
                design: .default
            ))
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct XlTitleItalicModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.xlTitle,
                weight: .regular,
                design: .default
            )
                .italic()
            )
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 7.0, *)
private struct XlTitleMonospaceModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.xlTitle,
                weight: .regular,
                design: .monospaced
            ))
    }
}

// MARK: - View Extensions

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// Styles a `Text` or `Button` with a regular style and a XL title font size.
    func xlTitleStyle() -> some View {
        self.modifier(XlTitleModifier())
    }
    
    /// Styles a `Text` or `Button` with a bold style and a XL title font size.
    func xlTitleBoldStyle() -> some View {
        self.modifier(XlTitleBoldModifier())
    }
    
    /// Styles a `Text` or `Button` with an italic style and a XL title font size.
    func xlTitleItalicStyle() -> some View {
        self.modifier(XlTitleItalicModifier())
    }
    
    /// Styles a `Text` or `Button` with a monospace style and a XL title font size.
    @available(watchOS 7.0, *)
    func xlTitleMonospaceStyle() -> some View {
        self.modifier(XlTitleMonospaceModifier())
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12.0, tvOS 16.0, watchOS 6.0, *)
struct XlTitleFont_Previews: PreviewProvider {
    
    static let mockString = "This is a string"
    
    static var previews: some View {
        VStack(spacing: 16) {
            Text(self.mockString)
                .xlTitleStyle()
            Text(self.mockString)
                .xlTitleBoldStyle()
            Text(self.mockString)
                .xlTitleItalicStyle()
            Text(self.mockString)
                .xlTitleMonospaceStyle()
        }
        .previewDisplayName("Styled Text(_:)")
        
        VStack(spacing: 16) {
            Button(self.mockString) {}
                .xlTitleStyle()
            Button(self.mockString) {}
                .xlTitleBoldStyle()
            Button(self.mockString) {}
                .xlTitleItalicStyle()
            Button(self.mockString) {}
                .xlTitleMonospaceStyle()
        }
        .previewDisplayName("Styled Button(_:)")
    }
}

#endif
