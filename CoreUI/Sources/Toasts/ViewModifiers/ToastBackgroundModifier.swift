//
//  ToastBackgroundModifier.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastBackgroundModifier

/// Applies a platform- and version-appropriate background to a toast.
///
/// Resolution order:
/// 1. **visionOS** — always uses `glassBackgroundEffect`, the native design.
/// 2. **iOS 26+ / macOS 26+ / tvOS 26+** — uses Liquid Glass via `.glassEffect(_:in:)`.
/// 3. **iOS / macOS / tvOS pre-26** — falls back to a translucent material (`.bar` / `.regularMaterial`).
private struct ToastBackgroundModifier: ViewModifier {

    let shape: ToastOptions.Shape

    func body(content: Content) -> some View {
        #if os(visionOS)
        switch self.shape {
        case .capsule:
            content
                .glassBackgroundEffect(in: .capsule)
        case .roundedRectangle:
            content
                .glassBackgroundEffect(in: .rect)
        }

        #else
        // iOS / macOS / tvOS — pick Liquid Glass on 26+, material on older OSes.
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, *) {
            switch self.shape {
            case .capsule:
                content
                    .glassEffect(.regular, in: .capsule)
            case .roundedRectangle:
                content
                    .glassEffect(.regular, in: .rect(cornerRadius: 10.0))
            }
        } else {
            #if os(tvOS)
            let material: Material = .regularMaterial
            #else
            let material: Material = .bar
            #endif

            switch self.shape {
            case .capsule:
                content
                    .background(material, in: Capsule())
                    .shadowIfLightColorScheme(radius: 1, y: 1)
            case .roundedRectangle:
                content
                    .background(material, in: RoundedRectangle(cornerRadius: 10.0))
                    .shadowIfLightColorScheme(radius: 1, y: 1)
            }
        }
        #endif
    }
}

// MARK: - ApplyToastBackground

extension View {

    func toastBackground(shape: ToastOptions.Shape) -> some View {
        self.modifier(ToastBackgroundModifier(shape: shape))
    }
}

#endif
