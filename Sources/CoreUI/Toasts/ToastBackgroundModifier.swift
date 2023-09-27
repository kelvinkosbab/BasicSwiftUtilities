//
//  ToastBackgroundModifier.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastBackgroundModifier

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
private struct ToastBackgroundModifier : ViewModifier {
    
    func body(content: Content) -> some View {
        #if os(tvOS)
        content
            .background(.regularMaterial, in: Capsule())
            .shadowIfLightColorScheme(radius: 1, y: 1)
        #else
        content
            .background(.bar, in: Capsule())
            .shadowIfLightColorScheme(radius: 1, y: 1)
        #endif
    }
}

// MARK: - ApplyToastBackground

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
public extension View {
    
    func toastBackground() -> some View {
        self.modifier(ToastBackgroundModifier())
    }
}

#endif
