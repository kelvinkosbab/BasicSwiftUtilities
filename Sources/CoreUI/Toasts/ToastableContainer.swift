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
    
    static let topCapsuleToastApi = ToastApi(options: ToastOptions(position: .top, shape: .capsule))
    static let bottomCapsuleToastApi = ToastApi(options: ToastOptions(position: .bottom, shape: .capsule))
    static let topRoundedRectangleToastApi = ToastApi(options: ToastOptions(position: .top, shape: .roundedRectangle))
    static let bottomRoundedRectangleToastApi = ToastApi(options: ToastOptions(position: .bottom, shape: .roundedRectangle))
    static let image: Image = Image(systemName: "heart.circle.fill")
    
    static var previews: some View {
        
        // MARK: - Top Capsule Previews
        
        NavigationView {
            List {
                
                Button("Top: Show Simple Title") {
                    self.topCapsuleToastApi.show(title: "Simple Title")
                }
                
                Button("Top: Show Title & Description") {
                    self.topCapsuleToastApi.show(
                        title: "Simple Title",
                        description: "Some Description"
                    )
                }
                
                Button("Top: Show Custom Content") {
                    self.topCapsuleToastApi.show(
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
                    self.topCapsuleToastApi.show(
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
                    self.topCapsuleToastApi.show(
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
                    self.topCapsuleToastApi.show(
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
            }
        }
        .toastableContainer(toastApi: self.topCapsuleToastApi)
        .previewDisplayName("Top Capsule Toast Tests")
        
        // MARK: - Bottom Capsule Previews
        
        NavigationView {
            List {
                
                Button("Bottom: Show Simple Title") {
                    self.bottomCapsuleToastApi.show(title: "Simple Title")
                }
                
                Button("Bottom: Show Title & Description") {
                    self.bottomCapsuleToastApi.show(
                        title: "Simple Title",
                        description: "Some Description"
                    )
                }
                
                Button("Top: Show Custom Content") {
                    self.bottomCapsuleToastApi.show(
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
                    self.bottomCapsuleToastApi.show(
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
                    self.bottomCapsuleToastApi.show(
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
                    self.bottomCapsuleToastApi.show(
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
            }
        }
        .toastableContainer(toastApi: self.bottomCapsuleToastApi)
        .previewDisplayName("Bottom Capsule Toast Tests")
        
        // MARK: - Top RoundedRectangle Previews
        
        NavigationView {
            List {
                
                Button("Top: Show Simple Title") {
                    self.topRoundedRectangleToastApi.show(title: "Simple Title")
                }
                
                Button("Top: Show Title & Description") {
                    self.topRoundedRectangleToastApi.show(
                        title: "Simple Title",
                        description: "Some Description"
                    )
                }
                
                Button("Top: Show Custom Content") {
                    self.topRoundedRectangleToastApi.show(
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
                    self.topRoundedRectangleToastApi.show(
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
                    self.topRoundedRectangleToastApi.show(
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
                    self.topRoundedRectangleToastApi.show(
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
            }
        }
        .toastableContainer(toastApi: self.topRoundedRectangleToastApi)
        .previewDisplayName("Top RoundedRectangle Toast Tests")
        
        // MARK: - Bottom RoundedRectangle Previews
        
        NavigationView {
            List {
                
                Button("Bottom: Show Simple Title") {
                    self.bottomRoundedRectangleToastApi.show(title: "Simple Title")
                }
                
                Button("Bottom: Show Title & Description") {
                    self.bottomRoundedRectangleToastApi.show(
                        title: "Simple Title",
                        description: "Some Description"
                    )
                }
                
                Button("Top: Show Custom Content") {
                    self.bottomRoundedRectangleToastApi.show(
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
                    self.bottomRoundedRectangleToastApi.show(
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
                    self.bottomRoundedRectangleToastApi.show(
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
                    self.bottomRoundedRectangleToastApi.show(
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
            }
        }
        .toastableContainer(toastApi: self.bottomRoundedRectangleToastApi)
        .previewDisplayName("Bottom RoundedRectangle Toast Tests")
    }
}

#endif
