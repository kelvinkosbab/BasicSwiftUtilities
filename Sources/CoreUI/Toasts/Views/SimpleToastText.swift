//
//  SimpleToastText.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - SimpleToastText

/// Defines a view for a primary or secondary styled text element.
public struct SimpleToastText: View {

    enum ForegroundStyle {
        case primary
        case secondary
    }

    /// Text to display.
    let text: String

    /// Style to apply to the text.
    let foregroundStyle: ForegroundStyle

    public var body: some View {
        Text(self.text)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .modifier(ForegroundStyleFontStyleModifier(foregroundStyle: self.foregroundStyle))
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .foregroundStyle(self.foregroundStyle == .primary ? .primary : .secondary)
    }
}

private struct ForegroundStyleFontStyleModifier: ViewModifier {

    let foregroundStyle: SimpleToastText.ForegroundStyle

    func body(content: Content) -> some View {
        switch self.foregroundStyle {
        case .primary:
            content
                .font(.system(.footnote, weight: .bold))
        case .secondary:
            content
                .font(.system(.footnote, weight: .light))
        }
    }
}

#endif
