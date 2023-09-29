//
//  SimpleToastText.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - SimpleToastText

/// TODO documentation
public struct SimpleToastText : View {
    
    enum ForegroundStyle {
        case primary
        case secondary
    }
    
    /// TODO documentation
    let text: String
    
    /// TODO documentation
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

private struct ForegroundStyleFontStyleModifier : ViewModifier {
    
    /// TODO documentation
    let foregroundStyle: SimpleToastText.ForegroundStyle
    
    func body(content: Content) -> some View {
        switch self.foregroundStyle {
        case .primary:
            if #available(iOS 16.0, *) {
                content
                    .font(.system(.footnote, weight: .bold))
            } else {
                content.font(.footnote.bold())
            }
        case .secondary:
            if #available(iOS 16.0, *) {
                content
                    .font(.system(.footnote, weight: .light))
            } else {
                content.font(.footnote.weight(.light))
            }
        }
    }
}

#endif
