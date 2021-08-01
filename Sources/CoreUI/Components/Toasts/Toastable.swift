//
//  Toastable.swift
//
//  Created by Kelvin Kosbab on 7/31/21.
//

import SwiftUI

// MARK: - ToastableModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ToastableContainerModifier : ViewModifier {
    
    @State var paddingTop: CGFloat = 0
    
    public init() {
        /// Register `this` to `ToastProvider`
    }
    
    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                content
                
                VStack {
                    ToastView(.constant(ToastContent(title: "One")))
                        .padding(.top, -geometry.safeAreaInsets.top - Spacing.base)
                    Spacer()
                }
                .padding(.top, Spacing.base)
            }
        }
    }
}

public protocol ToastableContainer {
    
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class Toast {
    
    public static func showToast(title: String) {
        _ = ToastContent(title: title,
                                    description: nil,
                                    image: nil,
                                    tintColor: nil)
    }
    
    public static func showToast(title: String,
                                 image: Image,
                                 imageTintColor: Color) {
        _ = ToastContent(title: title,
                                    description: nil,
                                    image: image,
                                    tintColor: imageTintColor)
    }
    
    public static func showToast(title: String,
                                 image: Image,
                                 isDestructive: Bool = false) {
        let tintColor = isDestructive ? AppColors.appDestructiveColor : AppColors.appTintColor
        _ = ToastContent(title: title,
                                    description: nil,
                                    image: image,
                                    tintColor: tintColor)
    }
    
    public static func showToast(title: String,
                                 description: String) {
        _ = ToastContent(title: title,
                                    description: description,
                                    image: nil,
                                    tintColor: nil)
    }
    
    public static func showToast(title: String,
                                 description: String,
                                 image: Image,
                                 imageTintColor: Color) {
        _ = ToastContent(title: title,
                                    description: description,
                                    image: image,
                                    tintColor: imageTintColor)
    }
    
    public static func showToast(title: String,
                                 description: String,
                                 image: Image,
                                 isDestructive: Bool = false) {
        let tintColor = isDestructive ? AppColors.appDestructiveColor : AppColors.appTintColor
        _ = ToastContent(title: title,
                                    description: description,
                                    image: image,
                                    tintColor: tintColor)
    }
}
