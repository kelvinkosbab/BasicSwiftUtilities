//
//  ToastStateManager.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastStateManager

@MainActor
protocol ToastStateDelegate: AnyObject {
    func didUpdate(toastState: ToastState)
}

/// Responsible for managing any incoming `showToast` requests. Incoming toasts will be queued up
/// until all toasts have been shown to the user.
@MainActor
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
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(prepareDuration * 1_000_000_000))

            // Show the toast
            withAnimation {
                self?.delegate?.didUpdate(toastState: .show(nextToast))
            }

            try? await Task.sleep(nanoseconds: UInt64(showDelay * 1_000_000_000))

            withAnimation {
                self?.delegate?.didUpdate(toastState: .hiding(nextToast))
            }

            // Wait for toast to hide
            try? await Task.sleep(nanoseconds: UInt64(animationDuration * 1_000_000_000))

            withAnimation {
                self?.delegate?.didUpdate(toastState: .none)
            }

            self?.isProcessingCurrentToast = false
            self?.processNextToast()
        }
    }
}

#endif
