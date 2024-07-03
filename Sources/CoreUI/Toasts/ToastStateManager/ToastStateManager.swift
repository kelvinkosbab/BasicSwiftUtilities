//
//  ToastStateManager.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastStateManager

protocol ToastStateDelegate : AnyObject {
    func didUpdate(toastState: ToastState)
}

/// Responsible for managing any incoming `showToast` requests. Incoming toasts will be queued up
/// until all toasts have been shown to the user.
class ToastStateManager {
    
    weak var delegate: ToastStateDelegate?
    private let options: ToastOptions
    private var toasts: [AnyView] = []
    private var isProcessingCurrentToast: Bool = false
    
    init(options: ToastOptions) {
        self.options = options
    }
    
    func show(toast: AnyView) {
        self.toasts.append(toast)
        self.processNextToast()
    }
    
    private func processNextToast() {
        
        guard !self.isProcessingCurrentToast else {
            return
        }
        
        guard self.toasts.count > 0 else {
            self.isProcessingCurrentToast = false
            self.delegate?.didUpdate(toastState: .none)
            return
        }
        
        self.isProcessingCurrentToast = true
        let nextToast = self.toasts.removeFirst()
        
        // Gather animation options
        let animationDuration = self.options.animationDuration
        let prepareDuration = self.options.prepareDuration
        let showDelay = animationDuration + self.options.showDuration
        
        withAnimation {
            self.delegate?.didUpdate(toastState: .prepare(nextToast))
        }
        
        // Prepare the toast for rendering
        DispatchQueue.main.asyncAfter(deadline: .now() + prepareDuration) { [weak self] in
            
            // Show the toast
            withAnimation {
                self?.delegate?.didUpdate(toastState: .show(nextToast))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + showDelay) { [weak self] in
                
                withAnimation {
                    self?.delegate?.didUpdate(toastState: .hiding(nextToast))
                }
                
                // Wiat for toast to hide
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
                    
                    withAnimation {
                        self?.delegate?.didUpdate(toastState: .none)
                    }
                    
                    self?.isProcessingCurrentToast = false
                    self?.processNextToast()
                }
            }
        }
    }
}

#endif
