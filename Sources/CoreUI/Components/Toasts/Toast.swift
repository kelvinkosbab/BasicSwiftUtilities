//
//  Toast.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import SwiftUI

// MARK: - Toast

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class Toast {
    
    private static var registeredContainer: [AppSessionTarget : ToastContainer] = [:]
    
    static func register(container: ToastContainer,
                         target: AppSessionTarget) {
        
        guard self.registeredContainer[target] == nil else {
            fatalError("Toast container has already been registred for target: \(target.rawValue)")
        }
        
        self.registeredContainer[target] = container
    }
    
    private static func containerNotConfiguredError(target: AppSessionTarget) -> String {
        return "Toast container not configured for target: \(target.rawValue)"
    }
    
    public static func show(title: String,
                            target: AppSessionTarget = .primary) {
        
        guard let container = self.registeredContainer[target] else {
            fatalError(self.containerNotConfiguredError(target: target))
        }
        
        let content = ToastContent(title: title,
                                   description: nil,
                                   image: nil,
                                   tintColor: nil)
        container.show(content)
    }
    
    public static func show(title: String,
                            image: Image,
                            imageTintColor: Color,
                            target: AppSessionTarget = .primary) {
        
        guard let container = self.registeredContainer[target] else {
            fatalError(self.containerNotConfiguredError(target: target))
        }
        
        let content = ToastContent(title: title,
                                   description: nil,
                                   image: image,
                                   tintColor: imageTintColor)
        container.show(content)
    }
    
    public static func show(title: String,
                            image: Image,
                            isDestructive: Bool = false,
                            target: AppSessionTarget = .primary) {
        
        guard let container = self.registeredContainer[target] else {
            fatalError(self.containerNotConfiguredError(target: target))
        }
        
        let tintColor = isDestructive ? AppColors.appDestructiveColor : AppColors.appTintColor
        let content = ToastContent(title: title,
                                   description: nil,
                                   image: image,
                                   tintColor: tintColor)
        container.show(content)
    }
    
    public static func show(title: String,
                            description: String,
                            target: AppSessionTarget = .primary) {
        
        guard let container = self.registeredContainer[target] else {
            fatalError(self.containerNotConfiguredError(target: target))
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
                            imageTintColor: Color,
                            target: AppSessionTarget = .primary) {
        
        guard let container = self.registeredContainer[target] else {
            fatalError(self.containerNotConfiguredError(target: target))
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
                            isDestructive: Bool = false,
                            target: AppSessionTarget = .primary) {
        
        guard let container = self.registeredContainer[target] else {
            fatalError(self.containerNotConfiguredError(target: target))
        }
        
        let tintColor = isDestructive ? AppColors.appDestructiveColor : AppColors.appTintColor
        let content = ToastContent(title: title,
                                   description: description,
                                   image: image,
                                   tintColor: tintColor)
        container.show(content)
    }
}
