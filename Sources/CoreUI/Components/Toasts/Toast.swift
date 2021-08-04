//
//  Toast.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import SwiftUI

// MARK: - Toast

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class Toast {
    
    private static var container: ToastContainer?
    private static let containerNotConfiguredError = "Toast container not configured"
    
    static func configure(container: ToastContainer) {
        self.container = container
    }
    
    public static func show(title: String) {
        
        guard let container = self.container else {
            fatalError(self.containerNotConfiguredError)
        }
        
        let content = ToastContent(title: title,
                                   description: nil,
                                   image: nil,
                                   tintColor: nil)
        container.show(content)
    }
    
    public static func show(title: String,
                            image: Image,
                            imageTintColor: Color) {
        
        guard let container = self.container else {
            fatalError(self.containerNotConfiguredError)
        }
        
        let content = ToastContent(title: title,
                                   description: nil,
                                   image: image,
                                   tintColor: imageTintColor)
        container.show(content)
    }
    
    public static func show(title: String,
                            image: Image,
                            isDestructive: Bool = false) {
        
        guard let container = self.container else {
            fatalError(self.containerNotConfiguredError)
        }
        
        let tintColor = isDestructive ? AppColors.appDestructiveColor : AppColors.appTintColor
        let content = ToastContent(title: title,
                                   description: nil,
                                   image: image,
                                   tintColor: tintColor)
        container.show(content)
    }
    
    public static func show(title: String,
                            description: String) {
        
        guard let container = self.container else {
            fatalError(self.containerNotConfiguredError)
        }
        
        let content = ToastContent(title: title,
                                   description: description,
                                   image: nil,
                                   tintColor: nil)
        container.show(content)
    }
    
    public static func show(title: String,
                            description: String,
                            image: Image,
                            imageTintColor: Color) {
        
        guard let container = self.container else {
            fatalError(self.containerNotConfiguredError)
        }
        
        let content = ToastContent(title: title,
                                   description: description,
                                   image: image,
                                   tintColor: imageTintColor)
        container.show(content)
    }
    
    public static func show(title: String,
                            description: String,
                            image: Image,
                            isDestructive: Bool = false) {
        
        guard let container = self.container else {
            fatalError(self.containerNotConfiguredError)
        }
        
        let tintColor = isDestructive ? AppColors.appDestructiveColor : AppColors.appTintColor
        let content = ToastContent(title: title,
                                   description: description,
                                   image: image,
                                   tintColor: tintColor)
        container.show(content)
    }
}
