//
//  ToastState.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastState

/// Defines the lifecycle of a toast.
enum ToastState {

    /// No toast shold be prepared or shown for rendering.
    case none

    /// Prepare a toast for display. A toast needs a short amount of time to define its bounds
    /// before it is ready to be animated onto the screen.
    case prepare(AnyView)

    /// The toast should be animated into view of the screen.
    case show(AnyView)

    /// The toast should be animatted out of the view of the screen.
    case hiding(AnyView)

    /// Utility returing whether or not the toast should be rendered and vvisible.
    var shouldBeVisible: Bool {
        switch self {
        case .none, .hiding, .prepare:
            false
        case .show:
            true
        }
    }
}

#endif
