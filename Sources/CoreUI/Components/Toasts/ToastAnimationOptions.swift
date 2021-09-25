//
//  ToastAnimationOptions.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import Foundation

// MARK: - ToastAnimationOptions

/// Defines how a toast animates before, during, and after rendering.
public struct ToastAnimationOptions {
    
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
    public init(animationDuration: TimeInterval = 0.2,
                prepareDuration: TimeInterval = 0.25,
                showDuration: TimeInterval = 1.0) {
        self.animationDuration = animationDuration
        self.prepareDuration = prepareDuration
        self.showDuration = showDuration
    }
}
