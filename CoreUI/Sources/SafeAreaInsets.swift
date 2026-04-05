//
//  SafeAreaInsets.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import SwiftUI

// MARK: - Getting SafeAreaInsets

@available(macOS, unavailable)
public extension EnvironmentValues {

    /// Provides the safe area insets of the application window.
    ///
    /// Usage:
    /// ```swift
    /// struct MyView: View {
    ///
    ///     @Environment(\.safeAreaInsets) private var safeAreaInsets
    ///
    ///     var body: some View {
    ///         Text("Hello")
    ///             .padding(safeAreaInsets)
    ///     }
    /// }
    /// ```
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

@available(macOS, unavailable)
private struct SafeAreaInsetsKey: @preconcurrency EnvironmentKey {

    @MainActor static var defaultValue: EdgeInsets {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let window = windowScene?.windows.first(where: { $0.isKeyWindow })
        return (window?.safeAreaInsets ?? .zero).insets
    }
}

@available(macOS, unavailable)
private extension UIEdgeInsets {

    var insets: EdgeInsets {
        EdgeInsets(
            top: top,
            leading: left,
            bottom: bottom,
            trailing: right
        )
    }
}

#endif
#endif
