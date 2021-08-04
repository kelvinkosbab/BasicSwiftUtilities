//
//  ToastableModifier.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import SwiftUI
import Core

// MARK: - ToastableModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ToastableModifier : ViewModifier {
    
    @State var paddingTop: CGFloat = 0
    
    private let animationOptions: ToastAnimationOptions
    @ObservedObject private var toastManager: ToastManager
    
    public init() {
        let animationOptions = ToastAnimationOptions()
        self.animationOptions = animationOptions
        let toastManager = ToastManager(animationOptions: animationOptions)
        self.toastManager = toastManager
        Toast.configure(container: toastManager)
    }
    
    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                content
                
                VStack {
                    VStack {
                        switch self.toastManager.currentToast {
                        case .none:
                            EmptyView()
                        case .show(let toast), .hiding(let toast), .prepare(let toast):
                            ToastView(.constant(toast))
                        }
                    }
                    .padding(.top, self.toastManager.currentToast.shouldBeVisible ? Spacing.small : -150)
                    .animation(.easeInOut(duration: self.animationOptions.animationDuration))
                    
                    Spacer()
                }
                .padding(.top, Spacing.base)
            }
        }
    }
}

// MARK: - Toastable

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// Enableds the attached container for ttoasts. The toasts will be bound to the container's safe area insets.
    func enableToasts() -> some View {
        self.modifier(ToastableModifier())
    }
}
