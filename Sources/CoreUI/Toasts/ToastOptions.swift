//
//  ToastOptions.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import Foundation

// MARK: - ToastOptions

/// Defines toast options.
public struct ToastOptions {
    
    // MARK: - Position
    
    public enum Position {
        case top
        case bottom
    }
    
    /// Where on the screen the toast will be displayed.
    let position: Position
    
    // MARK: - Shape
    
    public enum Shape {
        case capsule
        case roundedRectangle
    }
    
    /// Shape of the
    let shape: Shape
    
    // MARK: - Animations
    
    public enum AnimationStyle {
        case slide
        case pop
    }
    
    /// The amount of time the tost takes to move between shown or hidden.
    let animationDuration: TimeInterval
    
    /// The amount of time the toast needs before it is ready to be shown on the device.
    ///
    /// During initial development it was observed that the toast needed some time to "get ready"
    /// before it was animated on screen or else a poor user experience was observed.
    let prepareDuration: TimeInterval
    
    /// The amount of time the toast stays visible before dismissing.
    let showDuration: TimeInterval
    
    /// Creates `ToastOptions`.
    ///
    /// - Parameter position: The ``Position`` of where the toasts are displayed from. Default is `.top`.
    /// - Parameter shape: The ``Shape`` of the toast. Default is `.capsule`.
    /// - Parameter animationDuration: The duration of the toast animating in and out. Default is 0.5s.
    /// - Parameter prepareDuration: The duration for the views to populate the toast with it's content. Default is 0.2s.
    /// - Parameter showDuration: The duration that the toast stays in place.
    public init(
        position: Position = .top,
        shape: Shape = .capsule,
        animationDuration: TimeInterval = 0.75,
        prepareDuration: TimeInterval = 0.2,
        showDuration: TimeInterval = 1.0
    ) {
        self.position = position
        self.shape = shape
        self.animationDuration = animationDuration
        self.prepareDuration = prepareDuration
        self.showDuration = showDuration
    }
}

#endif
