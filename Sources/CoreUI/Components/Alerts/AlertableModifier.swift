//
//  AlertableModifier.swift
//
//  Created by Kelvin Kosbab on 8/16/21.
//

import SwiftUI
import Core

// MARK: - AlertableModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct AlertableModifier : ViewModifier {
    
    @ObservedObject private var alertManager: AlertManager
    
    init(target: AppSessionTarget) {
        let alertManager = AlertManager()
        self.alertManager = alertManager
        Alertable.register(container: alertManager, target: target)
    }
    
    func body(content: Content) -> some View {
        switch self.alertManager.currentAlert {
        case .none:
            content
        case .show(let alert, completion: let completion):
            if #available(iOS 15.0, *) {
                content
                    .alert(alert.title,
                           isPresented: self.$alertManager.isPresentingAlert,
                           actions: {
                        Button(alert.primaryAction.title,
                               role: alert.primaryAction.isDestructive ? .destructive : .cancel) {
                            alert.primaryAction.action()
                            completion()
                        }
                        if let secondaryAction = alert.secondaryAction {
                            Button(alert.primaryAction.title,
                                   role: secondaryAction.isDestructive ? .destructive : .cancel) {
                                secondaryAction.action()
                                completion()
                            }
                        }
                    },
                           message: {
                        EmptyView()
                    })
            } else if let secondaryAction = alert.secondaryAction {
                content
                    .alert(isPresented:self.$alertManager.isPresentingAlert) {
                        Alert(title: Text(alert.title),
                              message: Text(alert.message),
                              primaryButton: alert.primaryAction.isDestructive ? .destructive(Text(alert.primaryAction.title)) : .default(Text(alert.primaryAction.title)),
                              secondaryButton: secondaryAction.isDestructive ? .destructive(Text(secondaryAction.title)) : .default(Text(secondaryAction.title)))
                    }
            } else {
                content
                    .alert(isPresented:self.$alertManager.isPresentingAlert) {
                        Alert(title: Text(alert.title),
                              message: Text(alert.message),
                              dismissButton: alert.primaryAction.isDestructive ? .destructive(Text(alert.primaryAction.title)) : .default(Text(alert.primaryAction.title)))
                    }
            }
        }
    }
}

// MARK: - Alertable

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// Enables the attached container for alerts. The alerts will be bound to the container's safe area insets.
    ///
    /// If an app has multiple windows/scenes an alert target can be defined by expanding the
    /// `Toast.Target OptionalSet` type.
    ///
    /// - Parameter target: Target window/scene of the container. Default is `.primary`.
    func alertableContainer(target: AppSessionTarget = .primary) -> some View {
        self.modifier(AlertableModifier(target: target))
    }
}
