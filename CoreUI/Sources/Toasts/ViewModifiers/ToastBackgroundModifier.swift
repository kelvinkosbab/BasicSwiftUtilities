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
/// 2. **iOS 26+ / macOS 26+ / tvOS 26+** (when built with Xcode 26+) — uses
///    Liquid Glass via `.glassEffect(_:in:)`.
/// 3. **All other cases** — falls back to a translucent material (`.bar` /
///    `.regularMaterial`).
///
/// The Liquid Glass branch is gated by `#if compiler(>=6.2)` so the package
/// continues to build with older Xcode toolchains (which don't ship the iOS 26
/// SDK).
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

        #elseif compiler(>=6.2)
        // Built with Xcode 26+ — try Liquid Glass on supported OS versions,
        // fall back to a material on older systems.
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
            self.materialBackground(for: content)
        }

        #else
        // Built with Xcode <26 — Liquid Glass APIs are unavailable in this
        // SDK, so always use the material fallback.
        self.materialBackground(for: content)
        #endif
    }

    /// Translucent-material fallback for systems without Liquid Glass.
    @ViewBuilder
    private func materialBackground(for content: Content) -> some View {
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
}

// MARK: - ApplyToastBackground

extension View {

    func toastBackground(shape: ToastOptions.Shape) -> some View {
        self.modifier(ToastBackgroundModifier(shape: shape))
    }
}

#endif
