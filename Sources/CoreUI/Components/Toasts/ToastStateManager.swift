//
//  ToastStateManager.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import SwiftUI
import Core

// MARK: - ToastState

/// Defines the lifecycle of a toast.
@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
enum ToastState {
    
    /// No toast shold be prepared or shown for rendering.
    case none
    
    /// Prepare a toast for display. A toast needs a short amount of time to define its bounds
    /// before it is ready to be animated onto the screen.
    case prepare(ToastContent)
    
    /// The toast should be animated into view of the screen.
    case show(ToastContent)
    
    /// The toast should be animatted out of the view of the screen.
    case hiding(ToastContent)
    
    /// Utility returing whether or not the toast should be rendered and vvisible.
    var shouldBeVisible: Bool {
        switch self {
        case .none, .hiding, .prepare:
            return false
        case .show:
            return true
        }
    }
}

// MARK: - ToastStateManager

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
protocol ToastStateDelegate : AnyObject {
    func didUpdate(toastState: ToastState)
}

/// Responsible for managing any incoming `showToast` requests. Incoming toasts will be queued up
/// until all toasts have been shown to the user.
@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
class ToastStateManager  {
    
    weak var delegate: ToastStateDelegate?
    private let options: ToastOptions
    private var toasts: [ToastContent] = []
    private var isProcessingCurrentToast: Bool = false
    
    init(options: ToastOptions) {
        self.options = options
    }
    
    func show(_ content: ToastContent) {
        self.toasts.append(content)
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
