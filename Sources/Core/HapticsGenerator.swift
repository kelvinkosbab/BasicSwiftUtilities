//
//  HapticsGenerator.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

#if os(watchOS)
import WatchKit
#elseif os(iOS)
import UIKit
#endif

// MARK: - HapticsGenerator

public final class HapticsGenerator {
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - watchOS
    
    #if os(watchOS)
    
    public enum Haptic {
        
        case notification
        case success
        case failure
        case retry
        case start
        case stop
        case click
        
        internal var hapticType: WKHapticType {
            switch self {
            case .notification: return .notification
            case .success: return .success
            case .failure: return .failure
            case .retry: return .retry
            case .start: return .start
            case .stop: return .stop
            case .click: return .click
            }
        }
    }
    
    private let watchKitInterfaceDevice = WKInterfaceDevice.current()
    
    public final func generate(_ haptic: Haptic) {
        DispatchQueue.main.async {
            self.watchKitInterfaceDevice.play(haptic.hapticType)
        }
    }
    
    #elseif os(iOS)
    
    // MARK: - iOS
    
    public enum Haptic {
        case notification(NotificationHaptic)
        case selection
        case impact(ImpactHaptic)
    }
    
    public enum NotificationHaptic {
        
        case success
        case warning
        case error
        
        internal var feedbackType: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: return .success
            case .warning: return .warning
            case .error: return .error
            }
        }
    }
    
    public enum ImpactHaptic {
        
        case light
        case medium
        case heavy
        
        internal var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            }
        }
    }
    
    public final func generate(_ haptic: Haptic) {
        switch haptic {
        case .selection:
            let selection = UISelectionFeedbackGenerator()
            DispatchQueue.main.async {
                selection.selectionChanged()
            }
        case .notification(let haptic):
            let notification = UINotificationFeedbackGenerator()
            DispatchQueue.main.async {
                notification.notificationOccurred(haptic.feedbackType)
            }
        case .impact(let haptic):
            let impact = UIImpactFeedbackGenerator(style: haptic.feedbackStyle)
            DispatchQueue.main.async {
                impact.impactOccurred()
            }
        }
    }
    
    #endif
}
