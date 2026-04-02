//
//  ToastableContainer.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastableContainer

/// Container for displaying toasts in an application window.
///
/// Usage:
/// ```swift
/// // Define the toastableContainer
/// @main
/// struct CoreSampleApp: App {
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView(toastApi: self.toastApi)
///                 .toastableContainer()
///         }
///     }
/// }
///
/// // In a sub-component:
///
/// struct AnotherView: View {
///
///     @EnvironmentObject var toastApi: ToastApi
///
///     var body: some View {
///         Button("Bottom: Show Simple Title") {
///             self.toastApi.show(title: "Simple Title")
///         }
///     }
/// }
/// ```
struct ToastableContainer<Content>: View where Content: View {

    var content: () -> Content

    @ObservedObject private var toastApi: ToastApi

    public init(
        toastApi: ToastApi,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.toastApi = toastApi
        self.content = content
    }

    public var body: some View {
        #if os(visionOS)
        self.content()
            .ornament(
                visibility: self.toastApi.currentToastState.shouldBeVisible ? .visible : .hidden,
                attachmentAnchor: .scene(self.toastApi.options.position == .top ? .top : .bottom)
            ) {
                switch self.toastApi.currentToastState {
                case .none:
                    EmptyView()

                case .show(let toast), .hiding(let toast), .prepare(let toast):
                    toast
                        .glassBackgroundEffect()
                }
            }

        #else

        ZStack {
            self.content()

            GeometryReader { geometry in
                VStack {
                    switch self.toastApi.currentToastState {
                    case .none:
                        EmptyView()

                    case .show(let toast), .hiding(let toast), .prepare(let toast):
                        if self.toastApi.options.position == .bottom {
                            Spacer()
                        }

                        self.renderToast(toast: toast)

                        if self.toastApi.options.position == .top {
                            Spacer()
                        }
                    }
                }
                .modifier(AnimatedToastModifier(
                    toastApi: self.toastApi,
                    toastSize: geometry.size
                ))
            }
        }
        .environmentObject(self.toastApi)
        #if !os(macOS)
        .ignoresSafeArea()
        #endif

        #endif
    }

    private func renderToast(toast: AnyView) -> some View {
        HStack {
            Spacer()
            toast
            Spacer()
        }
    }
}

#if !os(visionOS)

// MARK: - AnimatedToastModifier

private struct AnimatedToastModifier: ViewModifier {

    #if !os(macOS)
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    #else
    private let safeAreaInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    #endif

    @ObservedObject var toastApi: ToastApi
    let toastSize: CGSize

    func body(content: Content) -> some View {
        switch self.toastApi.options.animationStyle {
        case .slide:
            content
                .padding(
                    self.toastApi.options.position == .top ? .top : .bottom,
                    self.getToastTopOffset()
                )
                .animation(
                    .easeIn(duration: self.toastApi.options.animationDuration),
                    value: self.toastApi.currentToastState.shouldBeVisible
                )

        case .pop:
            content
                .transition(.opacity.animation(.easeInOut(duration: self.toastApi.options.animationDuration)))
                .padding(
                    self.toastApi.options.position == .top ? .top : .bottom,
                    10 + (self.toastApi.options.position == .top ? self.safeAreaInsets.top : self.safeAreaInsets.bottom)
                )
        }
    }

    private func getToastTopOffset() -> CGFloat {
        if self.toastApi.currentToastState.shouldBeVisible {
            let position = self.toastApi.options.position
            #if !os(macOS)
            let safeArea = position == .top ? self.safeAreaInsets.top : self.safeAreaInsets.bottom
            #else
            let safeArea: CGFloat = 0
            #endif
            return max(safeArea, Spacing.base)
        } else {
            return -self.toastSize.height
        }
    }
}

#endif
#endif
