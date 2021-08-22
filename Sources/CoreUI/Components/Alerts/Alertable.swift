//
//  Alertable.swift
//
//  Created by Kelvin Kosbab on 8/16/21.
//

import SwiftUI

// MARK: - Alertable

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class Alertable {
    
    private static var registeredContainer: [AppSessionTarget : AlertableContainer] = [:]
    
    static func register(container: AlertableContainer,
                         target: AppSessionTarget) {
        
        guard self.registeredContainer[target] == nil else {
            fatalError("Alert container has already been registred for target: \(target.rawValue)")
        }
        
        self.registeredContainer[target] = container
    }
    
    private static func containerNotConfiguredError(target: AppSessionTarget) -> String {
        return "Alert container not configured for target: \(target.rawValue)"
    }
    
    public static func show(title: String,
                            message: String,
                            primaryAction: AlertContent.Action,
                            secondaryAction: AlertContent.Action? = nil,
                            target: AppSessionTarget = .primary) {
        
        guard let container = self.registeredContainer[target] else {
            fatalError(self.containerNotConfiguredError(target: target))
        }
        
        let content = AlertContent(title: title,
                                   message: message,
                                   primaryAction: primaryAction,
                                   secondaryAction: secondaryAction)
        container.show(content)
    }
}
