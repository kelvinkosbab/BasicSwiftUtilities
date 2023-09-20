//
//  FontBodyViewModifiers.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// rounded, serif, none

// MARK: - Body ViewModifiers

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct BodyModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.body,
                weight: .regular,
                design: .default
            ))
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct BodyBoldModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.body,
                weight: .bold,
                design: .default
            ))
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct BodyItalicModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(
                .system(
                    size: AppFont.Size.body,
                    weight: .regular,
                    design: .default
                )
                .italic()
            )
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 7.0, *)
private struct BodyMonospaceModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.body,
                weight: .regular,
                design: .monospaced
            ))
    }
}

// MARK: - View Extensions

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// Styles a `Text` or `Button` with a regular style and a body font size.
    func bodyStyle() -> some View {
        self.modifier(BodyModifier())
    }
    
    /// Styles a `Text` or `Button` with a bold style and a body font size.
    func bodyBoldStyle() -> some View {
        self.modifier(BodyBoldModifier())
    }
    
    /// Styles a `Text` or `Button` with an italic style and a body font size.
    func bodyItalicStyle() -> some View {
        self.modifier(BodyItalicModifier())
    }
    
    /// Styles a `Text` or `Button` with a monospace style and a body font size.
    @available(watchOS 7.0, *)
    func bodyMonospaceStyle() -> some View {
        self.modifier(BodyMonospaceModifier())
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12.0, tvOS 16.0, watchOS 6.0, *)
struct BodyFont_Previews: PreviewProvider {
    
    static let mockString = "This is a string"
    
    static var previews: some View {
        VStack(spacing: 16) {
            Text(self.mockString)
                .bodyStyle()
            Text(self.mockString)
                .bodyBoldStyle()
            Text(self.mockString)
                .bodyItalicStyle()
            Text(self.mockString)
                .bodyMonospaceStyle()
        }
        .previewDisplayName("Styled Text(_:)")
        
        VStack(spacing: 16) {
            Button(self.mockString) {}
                .bodyStyle()
            Button(self.mockString) {}
                .bodyBoldStyle()
            Button(self.mockString) {}
                .bodyItalicStyle()
            Button(self.mockString) {}
                .bodyMonospaceStyle()
        }
        .previewDisplayName("Styled Button(_:)")
    }
}

#endif
