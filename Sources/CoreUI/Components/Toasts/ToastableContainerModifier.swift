//
//  ToastableModifier.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import SwiftUI
import Core

// MARK: - ToastableContainer

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ToastableContainer<Content> : View where Content: View{
    
    var content: () -> Content
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    @ObservedObject private var dataSource: DataSource

    public init(target: AppSessionTarget,
                @ViewBuilder content: @escaping () -> Content) {
        self.dataSource = DataSource(target: target)
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            self.content()
            
            VStack {
                VStack {
                    switch self.dataSource.currentToastState {
                    case .none:
                        EmptyView()
                    case .show(let toast), .hiding(let toast), .prepare(let toast):
                        ToastView(.constant(toast))
                    }
                }
                .padding(.top, self.dataSource.currentToastState.shouldBeVisible ? self.safeAreaInsets.top + Spacing.small : -(self.safeAreaInsets.top + (self.safeAreaInsets.top / 2)))
                .animation(.easeInOut(duration: self.dataSource.animationOptions.animationDuration))
                
                Spacer()
            }
            .ignoreSafeAreaEdges(.all)
        }
    }
    
    // MARK: - ToastDataSource

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    private class DataSource : ObservableObject, ToastStateDelegate {
        
        @Published var currentToastState: ToastState = .none
        
        let animationOptions: ToastAnimationOptions
        private let toastStateManager: ToastStateManager
        
        init(target: AppSessionTarget) {
            self.animationOptions = ToastAnimationOptions()
            self.toastStateManager = ToastStateManager(animationOptions: animationOptions)
            
            self.toastStateManager.delegate = self
            Toast.register(manager: self.toastStateManager, target: target)
        }
        
        func didUpdate(toastState: ToastState) {
            self.currentToastState = toastState
        }
    }
}

// MARK: - ToastableContainerModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ToastableContainerModifier : ViewModifier {
    
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
