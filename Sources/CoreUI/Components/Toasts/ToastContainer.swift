//
//  ToastContainer.swift
//
//  Created by Kelvin Kosbab on 7/31/21.
//

import SwiftUI
import Core

// MARK: - ToastContainer

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
protocol ToastContainer {
    func show(_ content: ToastContent)
}

// MARK: - CurrentToastState

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
enum CurrentToastState {
    case none
    case prepare(ToastContent)
    case show(ToastContent)
    case hiding(ToastContent)
    
    var shouldBeVisible: Bool {
        switch self {
        case .none, .hiding, .prepare:
            return false
        case .show:
            return true
        }
    }
}

// MARK: - ToastManager

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
class ToastManager: ToastContainer, ObservableObject {
    
    @Published var currentToast: CurrentToastState = .none
    
    private let animationOptions: ToastAnimationOptions
    private var toasts: [ToastContent] = []
    private var isProcessingToasts: Bool = false
    
    init(animationOptions: ToastAnimationOptions) {
        self.animationOptions = animationOptions
    }
    
    func show(_ content: ToastContent) {
        self.toasts.append(content)
        self.processNextToast()
    }
    
    private func processNextToast() {
        
        guard !self.isProcessingToasts else {
            return
        }
        
        self.isProcessingToasts = true
        
        guard self.toasts.count > 0 else {
            self.isProcessingToasts = false
            self.currentToast = .none
            return
        }
        
        // Gather animation options
        let animationDuration = self.animationOptions.animationDuration
        let prepareDuration = self.animationOptions.prepareDuration
        let showDelay = animationDuration + self.animationOptions.showDuration
        
        let nextToast = self.toasts.removeFirst()
        
        withAnimation {
            self.currentToast = .prepare(nextToast)
        }
        
        // Prepare the toast for rendering
        DispatchQueue.main.asyncAfter(deadline: .now() + prepareDuration) { [weak self] in
            
            // Show the toast
            withAnimation {
                self?.currentToast = .show(nextToast)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + showDelay) { [weak self] in
                
                withAnimation {
                    self?.currentToast = .hiding(nextToast)
                }
                
                // Wiat for toast to hide
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
                    
                    withAnimation {
                        self?.currentToast = .none
                    }
                    
                    self?.isProcessingToasts = false
                    self?.processNextToast()
                }
            }
        }
    }
}
