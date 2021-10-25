//
//  ToastableContainer.swift
//
//  Created by Kelvin Kosbab on 10/1/21.
//

import SwiftUI

// MARK: - ToastableContainer

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ToastableContainer<Content> : View where Content: View{
    
    var content: () -> Content
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    @ObservedObject private var toastApi: ToastApi

    public init(toastApi: ToastApi,
                @ViewBuilder content: @escaping () -> Content) {
        self.toastApi = toastApi
        self.content = content
    }
    
    private func getToastTopOffset(toastSize: CGSize) -> CGFloat {
        if self.toastApi.currentToastState.shouldBeVisible {
            let position = self.toastApi.options.position
            let safeArea = position == .top ? self.safeAreaInsets.top : self.safeAreaInsets.bottom
            return max(safeArea, Spacing.base) + Spacing.small
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
        .ignoreSafeAreaEdges(.all)
    }
    
    private func renderToast(toast: ToastContent) -> some View {
        HStack {
            Spacer()
            ToastView(.constant(toast))
            Spacer()
        }
    }
}
