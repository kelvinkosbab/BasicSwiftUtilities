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
/// @main
/// struct CoreSampleApp: App {
///
///     let toastApi = ToastApi()
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView(toastApi: self.toastApi)
///                 .toastableContainer(toastApi: self.toastApi)
///         }
///     }
/// }
///
/// // In a sub-component:
/// Button("Bottom: Show Simple Title") {
///     self.toastApi.show(title: "Simple Title")
/// }
/// ```
@available(iOS 13.0, macOS 12.0, tvOS 15.0, *)
struct ToastableContainer<Content> : View where Content: View{
    
    var content: () -> Content
    
    #if !os(macOS)
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    #endif
    
    @ObservedObject private var toastApi: ToastApi

    public init(
        toastApi: ToastApi,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.toastApi = toastApi
        self.content = content
    }
    
    private func getToastTopOffset(toastSize: CGSize) -> CGFloat {
        if self.toastApi.currentToastState.shouldBeVisible {
            let position = self.toastApi.options.position
            #if !os(macOS)
            let safeArea = position == .top ? self.safeAreaInsets.top : self.safeAreaInsets.bottom
            #else
            let safeArea: CGFloat = 0
            #endif
            return max(safeArea, Spacing.base)
        } else {
            return -toastSize.height
        }
    }
    
    public var body: some View {
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
                .padding(self.toastApi.options.position == .top ? .top : .bottom, self.getToastTopOffset(toastSize: geometry.size))
                .animation(.easeInOut(duration: self.toastApi.options.animationDuration))
            }
        }
        #if !os(macOS)
        .ignoreSafeAreaEdges(.all)
        #endif
    }
    
    private func renderToast(toast: ToastContent) -> some View {
        HStack {
            Spacer()
            ToastView(.constant(toast))
            Spacer()
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12.0, tvOS 15.0, *)
struct ToastableContainer_Previews: PreviewProvider {
    
    static let topToastApi = ToastApi(options: ToastOptions(position: .top))
    static let bottomToastApi = ToastApi(options: ToastOptions(position: .bottom))
    static let image: Image = Image(systemName: "heart.circle.fill")
    
    static var previews: some View {
        
        // MARK: - Top Previews
        
        NavigationView {
            List {
                
                Button("Top: Show Simple Title") {
                    self.topToastApi.show(title: "Simple Title")
                }
                
                Button("Top: Show Title & Description") {
                    self.topToastApi.show(
                        title: "Simple Title",
                        description: "Some Description"
                    )
                }
                
                Button("Top: Show with Leading Image") {
                    self.topToastApi.show(
                        title: "Simple Title",
                        leading: .tintedImage(self.image, .green)
                    )
                }
                
                Button("Top: Show with Trailing Image") {
                    self.topToastApi.show(
                        title: "Simple Title",
                        trailing: .tintedImage(self.image, .blue)
                    )
                }
                
                Button("Top: Show with Leading and Trailing") {
                    self.topToastApi.show(
                        title: "Simple Title",
                        leading: .tintedImage(self.image, .green),
                        trailing: .tintedImage(self.image, .blue)
                    )
                }
            }
        }
        .toastableContainer(toastApi: self.topToastApi)
        .previewDisplayName("Top Toast Tests")
        
        // MARK: - Bottom Previews
        
        NavigationView {
            List {
                
                Button("Bottom: Show Simple Title") {
                    self.bottomToastApi.show(title: "Simple Title")
                }
                
                Button("Bottom: Show Title & Description") {
                    self.bottomToastApi.show(
                        title: "Simple Title",
                        description: "Some Description"
                    )
                }
                
                Button("Bottom: Show with Leading Image") {
                    self.bottomToastApi.show(
                        title: "Simple Title",
                        leading: .tintedImage(self.image, .green)
                    )
                }
                
                Button("Bottom: Show with Trailing Image") {
                    self.bottomToastApi.show(
                        title: "Simple Title",
                        trailing: .tintedImage(self.image, .blue)
                    )
                }
                
                Button("Show with Leading and Trailing") {
                    self.bottomToastApi.show(
                        title: "Simple Title",
                        leading: .tintedImage(self.image, .green),
                        trailing: .tintedImage(self.image, .blue)
                    )
                }
            }
        }
        .toastableContainer(toastApi: self.bottomToastApi)
        .previewDisplayName("Bottom Toast Tests")
    }
}

#endif
#endif
