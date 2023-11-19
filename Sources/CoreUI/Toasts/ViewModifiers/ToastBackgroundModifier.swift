//
//  ToastBackgroundModifier.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastBackgroundModifier

struct ToastBackgroundModifier : ViewModifier {
    
    let shape: ToastOptions.Shape
    
    func body(content: Content) -> some View {
        #if os(tvOS)
        switch self.shape {
        case .capsule:
            content
                .background(.regularMaterial, in: Capsule())
                .shadowIfLightColorScheme(radius: 1, y: 1)
        case .roundedRectangle:
            content
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10.0))
                .shadowIfLightColorScheme(radius: 1, y: 1)
        }
        #else
        switch self.shape {
        case .capsule:
            content
                .background(.bar, in: Capsule())
                .shadowIfLightColorScheme(radius: 1, y: 1)
        case .roundedRectangle:
            content
                .background(.bar, in: RoundedRectangle(cornerRadius: 10.0))
                .shadowIfLightColorScheme(radius: 1, y: 1)
        }
        #endif
    }
}

private struct ToastShapeModifier : ViewModifier {
    
    let shape: ToastOptions.Shape
    
    func body(content: Content) -> some View {
        switch self.shape {
        case .capsule:
            content
        case .roundedRectangle:
            content
        }
    }
}

// MARK: - ApplyToastBackground

extension View {
    
    func toastBackground(shape: ToastOptions.Shape) -> some View {
        self.modifier(ToastBackgroundModifier(shape: shape))
    }
}

#endif
