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
                GeometryReader { geometry in
                    HStack {
                        Spacer()
                        VStack {
                            switch self.dataSource.currentToastState {
                            case .none:
                                EmptyView()
                            case .show(let toast), .hiding(let toast), .prepare(let toast):
                                ToastView(.constant(toast))
                            }
                        }
                        .padding(.top, self.dataSource.currentToastState.shouldBeVisible ? (max(self.safeAreaInsets.top, Spacing.base) + Spacing.small) : -geometry.size.height)
                        .animation(.easeInOut(duration: self.dataSource.animationOptions.animationDuration))
                        Spacer()
                    }
                }
                
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
