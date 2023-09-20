//
//  FontTitleViewModifiers.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// MARK: - Title ViewModifiers

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct TitleModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.title,
                weight: .regular,
                design: .default
            ))
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct TitleBoldModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.title,
                weight: .bold,
                design: .default
            ))
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
private struct TitleItalicModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.title,
                weight: .regular,
                design: .default
            )
                .italic()
            )
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 7.0, *)
private struct TitleMonospaceModifier : ViewModifier {
    
    public func body(content: Content) -> some View {
        return content
            .font(.system(
                size: AppFont.Size.title,
                weight: .regular,
                design: .monospaced
            ))
    }
}

// MARK: - View Extensions

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public extension View {

    /// Styles a `Text` or `Button` with a regular style and a title font size.
    func titleStyle() -> some View {
        self.modifier(TitleModifier())
    }
    
    /// Styles a `Text` or `Button` with a bold style and a title font size.
    func titleBoldStyle() -> some View {
        self.modifier(TitleBoldModifier())
    }
    
    /// Styles a `Text` or `Button` with an italic style and a title font size.
    func titleItalicStyle() -> some View {
        self.modifier(TitleItalicModifier())
    }
    
    /// Styles a `Text` or `Button` with a monospace style and a title font size.
    @available(watchOS 7.0, *)
    func titleMonospaceStyle() -> some View {
        self.modifier(TitleMonospaceModifier())
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12.0, tvOS 16.0, watchOS 6.0, *)
struct TitleFont_Previews: PreviewProvider {
    
    static let mockString = "This is a string"
    
    static var previews: some View {
        VStack(spacing: 16) {
            Text(self.mockString)
                .titleStyle()
            Text(self.mockString)
                .titleBoldStyle()
            Text(self.mockString)
                .titleItalicStyle()
            Text(self.mockString)
                .titleMonospaceStyle()
        }
        .previewDisplayName("Styled Text(_:)")
        
        VStack(spacing: 16) {
            Button(self.mockString) {}
                .titleStyle()
            Button(self.mockString) {}
                .titleBoldStyle()
            Button(self.mockString) {}
                .titleItalicStyle()
            Button(self.mockString) {}
                .titleMonospaceStyle()
        }
        .previewDisplayName("Styled Button(_:)")
    }
}

#endif
