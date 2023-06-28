//
//  ToastBackgroundModifier.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastBackgroundModifier

@available(iOS 13.0, macOS 12.0, tvOS 15.0, *)
private struct ToastBackgroundModifier : ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    private let simulatedLightBarColor = Color(red: 236/255, green: 240/255, blue: 241/255)
    private let simulatedDarkBarColor = Color(red: 23/255, green: 33/255, blue: 42/255)
    
    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .background(.bar, in: Capsule())
            .shadowIfLightColorScheme(radius: 1, y: 1)
        #elseif os(tvOS)
        content
            .background(.regularMaterial, in: Capsule())
            .shadowIfLightColorScheme(radius: 1, y: 1)
        #else
        if #available(iOS 15.0, *) {
            content
                .background(.bar, in: Capsule())
                .shadowIfLightColorScheme(radius: 1, y: 1)
        } else {
            if colorScheme == .light {
                content
                    .background(self.simulatedLightBarColor)
                    .clipShape(Capsule())
                    .shadowIfLightColorScheme(radius: 1, y: 1)
            } else {
                content
                    .background(self.simulatedDarkBarColor)
                    .clipShape(Capsule())
                    .shadowIfLightColorScheme(radius: 1, y: 1)
            }
        }
        #endif
    }
}

// MARK: - ApplyToastBackground

@available(iOS 13.0, macOS 12.0, tvOS 15.0, *)
public extension View {
    
    func toastBackground() -> some View {
        self.modifier(ToastBackgroundModifier())
    }
}

#endif
