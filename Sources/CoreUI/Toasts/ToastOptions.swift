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

    /// Defines the supported shape for toasts.
    public enum Shape {
        case capsule
        case roundedRectangle
    }

    /// Defines the shape of the toast.
    let shape: Shape

    // MARK: - Animations

    /// Defines how toasts will be presented to the user.
    public enum AnimationStyle {

        /// Toast will slide in from the edge of the screen.
        case slide

        /// Toasts will animate and `pop` in place.
        case pop
    }

    /// Defines how toasts will be presented to the user.
    let animationStyle: AnimationStyle

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
    public init(
        position: Position = .top,
        shape: Shape = .capsule,
        style: AnimationStyle = .slide
    ) {
        self.position = position
        self.shape = shape
        self.animationStyle = style
        switch style {
        case .slide:
            self.animationDuration = 0.75
        case .pop:
            self.animationDuration = 0.2
        }
        self.prepareDuration = 0.2
        self.showDuration = 1.0
    }
}

#endif
