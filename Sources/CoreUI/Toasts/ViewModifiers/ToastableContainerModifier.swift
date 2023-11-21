//
//  ToastableModifier.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastableContainerModifier

private struct ToastableContainerModifier : ViewModifier {
    
    let toastApi: ToastApi
    
    init(options: ToastOptions) {
        self.init(toastApi: ToastApi(options: options))
    }
    
    init(toastApi: ToastApi) {
        self.toastApi = toastApi
    }
    
    func body(content: Content) -> some View {
        ToastableContainer(toastApi: self.toastApi) {
            content
        }
    }
}

// MARK: - Toastable

public extension View {
    
    /// Enables the attached container for toasts. The toasts will be bound to the container's safe area insets.
    ///
    /// SwiftUI usage:
    /// ```
    /// @main
    /// struct SampleApp: App {
    ///
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .toastableContainer()
    ///         }
    ///     }
    ///}
    /// ```
    ///
    /// - Parameter options: Customizable options for the toast..
    func toastableContainer(options: ToastOptions = ToastOptions()) -> some View {
        self.toastableContainer(toastApi: ToastApi(options: options))
    }
    
    /// Enables the attached container for toasts. The toasts will be bound to the container's safe area insets.
    ///
    /// SwiftUI usage:
    /// ```
    /// @main
    /// struct SampleApp: App {
    ///
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .toastableContainer()
    ///         }
    ///     }
    ///}
    /// ```
    ///
    /// - Parameter toastApi: API which manages the presentation of toasts.
    func toastableContainer(toastApi: ToastApi) -> some View {
        modifier(ToastableContainerModifier(toastApi: toastApi))
    }
}

#endif
