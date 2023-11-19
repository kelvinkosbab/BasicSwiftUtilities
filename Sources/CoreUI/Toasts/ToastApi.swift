//
//  ToastApi.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastApi

public class ToastApi : ObservableObject, ToastStateDelegate {
    
    @Published var currentToastState: ToastState = .none
    
    let options: ToastOptions
    private let toastStateManager: ToastStateManager
    
    public init(
        options: ToastOptions = ToastOptions()
    ) {
        self.options = options
        self.toastStateManager = ToastStateManager(options: options)
        self.toastStateManager.delegate = self
    }
    
    // MARK: - Showing Simple Toasts
    
    /// Shows a toast with a title.
    ///
    /// - Parameter title: Primary title message.
    public func show(
        title: String
    ) {
        let toast = Toast(
            shape: options.shape,
            title: title
        )
        self.toastStateManager.show(toast: AnyView(toast))
    }
    
    /// Shows a toast with a title and a description below the title.
    ///
    /// - Parameter title: Primary title message.
    /// - Parameter description: Optional string. This text will be displayed directly below the title.
    public func show(
        title: String,
        description: String
    ) {
        let toast = Toast(
            shape: options.shape,
            title: title,
            description: description
        )
        self.toastStateManager.show(toast: AnyView(toast))
    }
    
    // MARK: - Showing Toasts with Custom Content
    
    public func show<Content, Leading, Trailing>(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) where Content: View, Leading: View, Trailing: View {
        let toast = Toast(
            shape: self.options.shape,
            content: content,
            leading: leading,
            trailing: trailing
        )
        self.toastStateManager.show(toast: AnyView(toast))
    }
    
    public func show<Content, Trailing>(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) where Content: View, Trailing: View {
        let toast = Toast(
            shape: options.shape,
            content: content,
            trailing: trailing
        )
        self.toastStateManager.show(toast: AnyView(toast))
    }
    
    /// TODO documentation
    public func show<Content, Leading>(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder leading: @escaping () -> Leading
    ) where Content: View, Leading: View {
        let toast = Toast(
            shape: options.shape,
            content: content,
            leading: leading
        )
        self.toastStateManager.show(toast: AnyView(toast))
    }
    
    /// TODO documentation
    public func show<Content>(
        @ViewBuilder content: @escaping () -> Content
    ) where Content: View {
        let toast = Toast(
            shape: options.shape,
            content: content
        )
        self.toastStateManager.show(toast: AnyView(toast))
    }
    
//    /// Shows a toast.
//    ///
//    /// - Parameter title: Primary title message.
//    /// - Parameter description: Optional string. This text will be displayed directly below the title.
//    /// - Parameter leading: Content to be displayed on the leading edge of the toast.
//    /// - Parameter trailing: Content to be displayed on the trailing edge of the toast.
//    public func show(
//        title: String,
//        description: String,
//        leading: ToastImageContent = .none,
//        trailing: ToastImageContent = .none
//    ) {
//        self.show(
//            title: .string(title),
//            description: .string(description),
//            leading: leading,
//            trailing: trailing
//        )
//    }
//    
//    /// Shows a toast.
//    ///
//    /// - Parameter title: Primary title message.
//    /// - Parameter description: Optional description. This content will be displayed directly below the title.
//    /// - Parameter leading: Content to be displayed on the leading edge of the toast.
//    /// - Parameter trailing: Content to be displayed on the trailing edge of the toast.
//    public func show(
//        title: String,
//        description: ToastSimpleContent? = nil,
//        leading: ToastImageContent = .none,
//        trailing: ToastImageContent = .none
//    ) {
//        self.show(
//            title: .string(title),
//            description: description,
//            leading: leading,
//            trailing: trailing
//        )
//    }
//    
//    /// Shows a toast.
//    ///
//    /// - Parameter title: Primary title content.
//    /// - Parameter description: Optional description. This content will be displayed directly below the title.
//    /// - Parameter leading: Content to be displayed on the leading edge of the toast.
//    /// - Parameter trailing: Content to be displayed on the trailing edge of the toast.
//    public func show(
//        title: ToastSimpleContent,
//        description: ToastSimpleContent? = nil,
//        leading: ToastImageContent = .none,
//        trailing: ToastImageContent = .none
//    ) {
//        let content = ToastContent(
//            title: title,
//            description: description,
//            leading: leading,
//            trailing: trailing
//        )
//        self.toastStateManager.show(content)
//    }
    
    // MARK: - ToastStateDelegate
    
    func didUpdate(toastState: ToastState) {
        self.currentToastState = toastState
    }
}

#endif
