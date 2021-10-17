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
            return max(self.safeAreaInsets.top, Spacing.base) + Spacing.small
        } else {
            return -toastSize.height
        }
    }
    
    public var body: some View {
        ZStack {
            self.content()
            
            VStack {
                GeometryReader { geometry in
                    HStack {
                        Spacer()
                        VStack {
                            switch self.toastApi.currentToastState {
                            case .none:
                                EmptyView()
                            case .show(let toast), .hiding(let toast), .prepare(let toast):
                                ToastView(.constant(toast))
                            }
                        }
                        .padding(.top, self.getToastTopOffset(toastSize: geometry.size))
                        .animation(.easeInOut(duration: self.toastApi.animationOptions.animationDuration))
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .ignoreSafeAreaEdges(.all)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ToastableWindow<Content> : View where Content: View{
    
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
            return max(self.safeAreaInsets.top, Spacing.base) + Spacing.small
        } else {
            return -toastSize.height
        }
    }
    
    public var body: some View {
        ZStack {
            self.content()
            
            VStack {
                GeometryReader { geometry in
                    HStack {
                        Spacer()
                        VStack {
                            switch self.toastApi.currentToastState {
                            case .none:
                                EmptyView()
                            case .show(let toast), .hiding(let toast), .prepare(let toast):
                                ToastView(.constant(toast))
                            }
                        }
                        .padding(.top, self.getToastTopOffset(toastSize: geometry.size))
                        .animation(.easeInOut(duration: self.toastApi.animationOptions.animationDuration))
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .ignoreSafeAreaEdges(.all)
        }
    }
}
