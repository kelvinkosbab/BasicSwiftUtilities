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
@available(iOS 13.0, tvOS 15.0, watchOS 6.0, *)
@available(iOS, deprecated: 15.0)
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
@available(iOS 13.0, tvOS 15.0, watchOS 6.0, *)
@available(iOS, deprecated: 15.0)
private struct SafeAreaInsetsKey: EnvironmentKey {
    
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

@available(macOS, unavailable)
@available(iOS 13.0, tvOS 15.0, watchOS 6.0, *)
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

// MARK: - Ignore Safe Area Edges

@available(macOS, unavailable)
@available(iOS 13.0, tvOS 15.0, watchOS 6.0, *)
private struct IgnoresSafeAreaModifier : ViewModifier {
    
    let edges: Edge.Set
    
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content
                .ignoresSafeArea(.all, edges: self.edges)
        } else {
            content
                .edgesIgnoringSafeArea(self.edges)
        }
    }
}

@available(macOS, unavailable)
@available(iOS 13.0, tvOS 15.0, watchOS 6.0, *)
internal extension View {
    
    func ignoreSafeAreaEdges(_ edges: Edge.Set) -> some View {
        self.modifier(IgnoresSafeAreaModifier(edges: edges))
    }
}

#endif
#endif
