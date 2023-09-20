//
//  FontFootnoteViewModifiers.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// MARK: - Footnote ViewModifiers

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct FootnoteModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.footnote,
                weight: .regular,
                design: .default
            ))
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct FootnoteBoldModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.footnote,
                weight: .bold,
                design: .default
            ))
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct FootnoteItalicModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.footnote,
                weight: .regular,
                design: .default
            )
                .italic()
            )
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 7.0, *)
private struct FootnoteMonospaceModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.footnote,
                weight: .regular,
                design: .monospaced
            ))
    }
}

// MARK: - View Extensions

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// Styles a `Text` or `Button` with a regular style and a footnote font size.
    func footnoteStyle() -> some View {
        self.modifier(FootnoteModifier())
    }
    
    /// Styles a `Text` or `Button` with a bold style and a footnote font size.
    func footnoteBoldStyle() -> some View {
        self.modifier(FootnoteBoldModifier())
    }
    
    /// Styles a `Text` or `Button` with an italic style and a footnote font size.
    func footnoteItalicStyle() -> some View {
        self.modifier(FootnoteBoldModifier())
    }
    
    /// Styles a `Text` or `Button` with a monospace style and a footnote font size.
    @available(watchOS 7.0, *)
    func footnoteMonospaceStyle() -> some View {
        self.modifier(FootnoteMonospaceModifier())
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12.0, tvOS 16.0, watchOS 6.0, *)
struct FootnoteFont_Previews: PreviewProvider {
    
    static let mockString = "This is a string"
    
    static var previews: some View {
        VStack(spacing: 16) {
            Text(self.mockString)
                .footnoteStyle()
            Text(self.mockString)
                .footnoteBoldStyle()
            Text(self.mockString)
                .footnoteItalicStyle()
            Text(self.mockString)
                .footnoteMonospaceStyle()
        }
        .previewDisplayName("Styled Text(_:)")
        
        VStack(spacing: 16) {
            Button(self.mockString) {}
                .footnoteStyle()
            Button(self.mockString) {}
                .footnoteBoldStyle()
            Button(self.mockString) {}
                .footnoteItalicStyle()
            Button(self.mockString) {}
                .footnoteMonospaceStyle()
        }
        .previewDisplayName("Styled Button(_:)")
    }
}

#endif
