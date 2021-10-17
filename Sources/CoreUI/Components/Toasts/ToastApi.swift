//
//  ToastApi.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import SwiftUI

// MARK: - ToastApi

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class ToastApi : ObservableObject, ToastStateDelegate {
    
    @Published var currentToastState: ToastState = .none
    
    let animationOptions: ToastAnimationOptions
    private let toastStateManager: ToastStateManager
    
    public init(animationOptions: ToastAnimationOptions = ToastAnimationOptions()) {
        self.animationOptions = animationOptions
        self.toastStateManager = ToastStateManager(animationOptions: animationOptions)
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
