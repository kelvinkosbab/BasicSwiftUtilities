//
//  ToastApi.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import SwiftUI

// MARK: - ToastApi

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
public class ToastApi : ObservableObject, ToastStateDelegate {
    
    @Published var currentToastState: ToastState = .none
    
    let options: ToastOptions
    private let toastStateManager: ToastStateManager
    
    public init(options: ToastOptions = ToastOptions()) {
        self.options = options
        self.toastStateManager = ToastStateManager(options: options)
        self.toastStateManager.delegate = self
    }
    
    // MARK: - Showing Toasts
    
    /// Shows a toast.
    ///
    /// - Parameter title: Primary title message.
    /// - Parameter description: Optional description. This text will be displayed directly below the title.
    /// - Parameter leading: Content to be displayed on the leading edge of the toast.
    /// - Parameter trailing: Content to be displayed on the trailing edge of the toast.
    public func show(title: String,
                     description: String? = nil,
                     leading: ToastContent.SubContent = .none,
                     trailing: ToastContent.SubContent = .none) {
        let content = ToastContent(title: title,
                                   description: description,
                                   leading: leading,
                                   trailing: trailing)
        self.toastStateManager.show(content)
    }
    
    // MARK: - ToastStateDelegate
    
    func didUpdate(toastState: ToastState) {
        self.currentToastState = toastState
    }
}

#endif
