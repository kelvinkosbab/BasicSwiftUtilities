//
//  ToastBackgroundModifier.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastBackgroundModifier

struct ToastBackgroundModifier : ViewModifier {
    
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

extension View {
    
    func toastBackground() -> some View {
        self.modifier(ToastBackgroundModifier())
    }
}

#endif
