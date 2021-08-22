//
//  AlertableContainer.swift
//
//  Created by Kelvin Kosbab on 8/16/21.
//

import SwiftUI
import Core

// MARK: - AlertableContainer

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
protocol AlertableContainer {
    
    func show(_ content: AlertContent)
}

// MARK: - CurrentAlertState

/// Defines the lifecycle of a toast.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
enum CurrentAlertState {
    
    /// No alert shold be prepared or shown for rendering.
    case none
    
    /// The alert should be animated into view of the screen.
    case show(AlertContent, completion: () -> Void)
    
    /// Utility returing whether or not the alert should be rendered and vvisible.
    var shouldBeVisible: Bool {
        switch self {
        case .none:
            return false
        case .show:
            return true
        }
    }
}

// MARK: - AlertManager

/// Responsible for managing any incoming `showAlert` requests. Incoming alerts will be queued up
/// until all alerts have been shown to the user.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
class AlertManager: AlertableContainer, ObservableObject {
    
    @Published var isPresentingAlert: Bool = false
    @Published var currentAlert: CurrentAlertState = .none
    
    private var alerts: [AlertContent] = []
    private var isProcessingCurrentAlert: Bool = false
    
    func show(_ content: AlertContent) {
        self.alerts.append(content)
        self.processNextAlert()
    }
    
    func processNextAlert() {
        
        guard !self.isProcessingCurrentAlert else {
            return
        }
        
        guard self.alerts.count > 0 else {
            self.isProcessingCurrentAlert = false
            self.isPresentingAlert = false
            return
        }
        
        self.isProcessingCurrentAlert = true
        let nextAlert = self.alerts.removeFirst()
        
        // Show the alert
        self.currentAlert = .show(nextAlert, completion: { [weak self] in
            self?.dismissCurrentAlert()
        })
        self.isPresentingAlert = true
    }
    
    private func dismissCurrentAlert() {
        
        self.isPresentingAlert = false
        self.currentAlert = .none
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.isProcessingCurrentAlert = false
            self?.processNextAlert()
        }
    }
}
