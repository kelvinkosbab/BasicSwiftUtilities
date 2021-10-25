//
//  ToastOptions.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import Foundation

// MARK: - ToastOptions

/// Defines toast options.
public struct ToastOptions {
    
    // MARK - Position
    
    public enum Position {
        case top
        case bottom
    }
    
    /// Where on the screen the toast will be displayed.
    let position: Position
    
    // MARK - Animations
    
    /// The amount of time the tost takes to move between shown or hidden.
    let animationDuration: TimeInterval
    
    /// The amount of time the toast needs before it is ready to be shown on the device.
    ///
    /// During initial development it was observed that the toast needed some time to "get ready"
    /// before it was animated on screen or else a poor user experience was observed.
    let prepareDuration: TimeInterval
    
    /// The amount of time the toast stays visible before dismissing.
    let showDuration: TimeInterval
    
    /// Constructor.
    public init(position: Position = .top,
                animationDuration: TimeInterval = 0.5,
                prepareDuration: TimeInterval = 0.2,
                showDuration: TimeInterval = 1.0) {
        self.position = position
        self.animationDuration = animationDuration
        self.prepareDuration = prepareDuration
        self.showDuration = showDuration
    }
}
