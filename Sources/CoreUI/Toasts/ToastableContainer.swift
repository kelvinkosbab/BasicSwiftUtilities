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
struct ToastableContainer<Content> : View where Content: View {
    
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
                .animation(.easeInOut, value: self.toastApi.options.animationDuration)
            }
        }
        #if !os(macOS)
        .ignoreSafeAreaEdges(.all)
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

// MARK: - Preview

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
                
                Button("Top: Show Custom Content") {
                    self.topToastApi.show(
                        content: {
                            HStack {
                                Circle()
                                    .foregroundColor(.cyan)
                                    .padding()
                                Rectangle()
                                    .foregroundColor(.green)
                                    .padding()
                            }
                        }
                    )
                }
                
                Button("Top: Show Custom Content & Leading") {
                    self.topToastApi.show(
                        content: {
                            Text("Hello there")
                                .font(.body)
                                .foregroundColor(.primary)
                        },
                        leading: {
                            Image(systemName: "heart.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                        }
                    )
                }
                
                Button("Top: Show Custom Content & Trailing") {
                    self.topToastApi.show(
                        content: {
                            Text("Hello there")
                                .font(.body)
                                .foregroundColor(.primary)
                        },
                        trailing: {
                            Image(systemName: "person.3.sequence.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(
                                    .linearGradient(colors: [.red, .clear], startPoint: .top, endPoint: .bottomTrailing),
                                    .linearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottomTrailing),
                                    .linearGradient(colors: [.blue, .clear], startPoint: .top, endPoint: .bottomTrailing)
                                )
                        }
                    )
                }
                
                Button("Top: Show Custom Content & Leading & Trailing") {
                    self.topToastApi.show(
                        content: {
                            VStack(spacing: Spacing.tiny) {
                                Text("Hello there")
                                    .font(.footnote)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                                Text("Hello there")
                                    .font(.footnote)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                            }
                        },
                        leading: {
                            Image(systemName: "heart.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                        },
                        trailing: {
                            Image(systemName: "person.3.sequence.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.blue, .green, .red)
                        }
                    )
                }
                
//                Button("Top: Show with Leading Image") {
//                    self.topToastApi.show(
//                        title: "Simple Title",
//                        leading: .tintedImage(self.image, .green)
//                    )
//                }
//                
//                Button("Top: Show with Trailing Image") {
//                    self.topToastApi.show(
//                        title: "Simple Title",
//                        trailing: .tintedImage(self.image, .blue)
//                    )
//                }
//                
//                Button("Top: Show with Leading and Trailing") {
//                    self.topToastApi.show(
//                        title: "Simple Title",
//                        leading: .tintedImage(self.image, .green),
//                        trailing: .tintedImage(self.image, .blue)
//                    )
//                }
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
                
                Button("Top: Show Custom Content") {
                    self.bottomToastApi.show(
                        content: {
                            HStack {
                                Circle()
                                    .foregroundColor(.cyan)
                                    .padding()
                                Rectangle()
                                    .foregroundColor(.green)
                                    .padding()
                            }
                        }
                    )
                }
                
                Button("Top: Show Custom Content & Leading") {
                    self.bottomToastApi.show(
                        content: {
                            Text("Hello there")
                                .font(.body)
                                .foregroundColor(.primary)
                        },
                        leading: {
                            Image(systemName: "heart.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                        }
                    )
                }
                
                Button("Top: Show Custom Content & Trailing") {
                    self.bottomToastApi.show(
                        content: {
                            Text("Hello there")
                                .font(.body)
                                .foregroundColor(.primary)
                        },
                        trailing: {
                            Image(systemName: "person.3.sequence.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(
                                    .linearGradient(colors: [.red, .clear], startPoint: .top, endPoint: .bottomTrailing),
                                    .linearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottomTrailing),
                                    .linearGradient(colors: [.blue, .clear], startPoint: .top, endPoint: .bottomTrailing)
                                )
                        }
                    )
                }
                
                Button("Top: Show Custom Content & Leading & Trailing") {
                    self.bottomToastApi.show(
                        content: {
                            VStack(spacing: Spacing.tiny) {
                                Text("Hello there")
                                    .font(.footnote)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                                Text("Hello there")
                                    .font(.footnote)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                            }
                        },
                        leading: {
                            Image(systemName: "heart.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                        },
                        trailing: {
                            Image(systemName: "person.3.sequence.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.blue, .green, .red)
                        }
                    )
                }
                
//                Button("Bottom: Show with Leading Image") {
//                    self.bottomToastApi.show(
//                        title: "Simple Title",
//                        leading: .tintedImage(self.image, .green)
//                    )
//                }
//                
//                Button("Bottom: Show with Trailing Image") {
//                    self.bottomToastApi.show(
//                        title: "Simple Title",
//                        trailing: .tintedImage(self.image, .blue)
//                    )
//                }
//                
//                Button("Show with Leading and Trailing") {
//                    self.bottomToastApi.show(
//                        title: "Simple Title",
//                        leading: .tintedImage(self.image, .green),
//                        trailing: .tintedImage(self.image, .blue)
//                    )
//                }
            }
        }
        .toastableContainer(toastApi: self.bottomToastApi)
        .previewDisplayName("Bottom Toast Tests")
    }
}

#endif
