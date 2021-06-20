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

/// Generates haptics for `iOS` and `watchOS`.
public final class HapticsGenerator {
    
    // MARK: - Init
    
    /// Constructor.
    public init() {}
    
    // MARK: - watchOS
    
    #if os(watchOS)
    
    /// Generates a haptic on the device.
    ///
    /// - Parameter haptic: Haptic type to generate.
    public final func generate(_ haptic: WKHapticType) {
        DispatchQueue.main.async {
            WKInterfaceDevice.current().play(haptic)
        }
    }
    
    #elseif os(iOS)
    
    // MARK: - iOS
    
    /// Wraps existing `UIKit` haptic feedback types.
    ///
    /// See `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`, and
    /// `UISelectionFeedbackGenerator` for more information.
    public enum Haptic {
        
        /// Used to give user feedback when an impact between UI elements occurs.
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        
        /// Used to give user feedback when an notification is displayed.
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        
        /// Used to give user feedback when a selection changes.
        case selection
    }
    
    /// Generates a haptic on the device.
    ///
    /// - Parameter haptic: Haptic type to generate.
    public final func generate(_ haptic: Haptic) {
        switch haptic {
        case .selection:
            DispatchQueue.main.async {
                let selectionHaptic = UISelectionFeedbackGenerator()
                selectionHaptic.selectionChanged()
            }
        case .notification(let haptic):
            DispatchQueue.main.async {
                let notificationHaptic = UINotificationFeedbackGenerator()
                notificationHaptic.notificationOccurred(haptic)
            }
        case .impact(let haptic):
            DispatchQueue.main.async {
                let impactHaptic = UIImpactFeedbackGenerator(style: haptic)
                impactHaptic.impactOccurred()
            }
        }
    }
    
    #endif
}
