//
//  Toast.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import SwiftUI

// MARK: - Toast

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class Toast {
    
    private static var registeredManagers: [AppSessionTarget : ToastStateManager] = [:]
    
    static func register(manager: ToastStateManager,
                         target: AppSessionTarget) {
        
        guard self.registeredManagers[target] == nil else {
            fatalError("Toast manager has already been registred for target: \(target.rawValue)")
        }
        
        self.registeredManagers[target] = manager
    }
    
    private static func managerNotConfiguredError(target: AppSessionTarget) -> String {
        return "Toast manager not configured for target: \(target.rawValue)"
    }
    
    /// Shows a toast.
    ///
    /// - Parameter title: Primary title message.
    /// - Parameter description: Optional description. This text will be displayed directly below the title.
    /// - Parameter leadingImage: Optional image and optional tint color displayed on tthe leading edge of the toast.
    /// - Parameter trailingImage: Optional image and optional tint color displayed on tthe trailing edge of the toast.
    /// - Parameter target: Target window to show the toast from.
    public static func show(title: String,
                            description: String? = nil,
                            leadingImage: (image: Image, tintColor: Color?)? = nil,
                            trailingImage: (image: Image, tintColor: Color?)? = nil,
                            target: AppSessionTarget = .primary) {
        
        guard let manager = self.registeredManagers[target] else {
            fatalError(self.managerNotConfiguredError(target: target))
        }
        
        let content = ToastContent(title: title,
                                   description: description,
                                   leadingImage: leadingImage,
                                   trailingImage: trailingImage)
        manager.show(content)
    }
}
