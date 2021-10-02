//
//  ToastableModifier.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import SwiftUI
import Core

// MARK: - ToastableContainerModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct ToastableContainerModifier : ViewModifier {
    
    @State var paddingTop: CGFloat = 0
    let target: AppSessionTarget
    let animationOptions: ToastAnimationOptions
    
    init(target: AppSessionTarget,
         animationOptions: ToastAnimationOptions = ToastAnimationOptions()) {
        self.target = target
        self.animationOptions = animationOptions
    }
    
    func body(content: Content) -> some View {
        ToastableContainer(target: self.target,
                           content: { content })
    }
}

// MARK: - Toastable

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// Enables the attached container for toasts. The toasts will be bound to the container's safe area insets.
    ///
    /// If an app has multiple windows/scenes a toast target can be defined by expanding the
    /// `Toast.Target OptionalSet` type.
    ///
    /// SwiftUI usage:
    /// ```
    /// @main
    /// struct CoreSampleApp: App {
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .toastableContainer(target: .primary)
    ///         }
    ///     }
    ///}
    /// ```
    ///
    /// - Parameter target: Target window/scene of the container. Default is `.primary`.
    func toastableContainer(target: AppSessionTarget = .primary) -> some View {
        self.modifier(ToastableContainerModifier(target: target))
    }
}
