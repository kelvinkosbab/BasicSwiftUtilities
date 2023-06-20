//
//  PresentationMode.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

// MARRK: - PresentationMode

/// Defines modes in which view controllers can be presented. `default` is `.formSheet`
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 12.0, tvOS 12.0, *)
public enum PresentationMode {
    
    /// Default presentation mode. See ``PresentationMode.formSheet``
    public static let `default`: PresentationMode = .formSheet
    
    /// The presentation is modal.
    ///
    /// - Note: This can be used to define custom presentation styles.
    case modal(
        presentationStyle: UIModalPresentationStyle,
        transitionStyle: UIModalTransitionStyle
    )
    
    /// When the view controller is presented, the current view fades out while the new view fades in at the same time.
    /// On dismissal, a similar type of cross-fade is used to return to the original view.
    ///
    /// For more information see [`UIModalTransitionStyle.crossDissolve`](https://developer.apple.com/documentation/uikit/uimodaltransitionstyle/crossdissolve)
    case crossDissolve
    
    /// When the view controller is presented, its view slides up from the bottom of the screen. On dismissal, the view slides
    /// back down. This is the default transition style.
    ///
    /// For more information see [`UIModalTransitionStyle.coverVertical`](https://developer.apple.com/documentation/uikit/uimodaltransitionstyle/coververtical)
    case formSheet
    
    /// If the parent view controller is a `UINavigationController` the ``PresentableController`` view
    /// controller will be pushed on top of the stack. If the parent view controller is a `UISplitViewController` the
    ///  ``PresentableController`` view controller will be "showed" in the detail depending on how the
    ///  `UISplitViewController` was presented and on the form factor.
    case show
    
    var isShow: Bool {
        switch self {
        case .show:
            return true
        default:
            return false
        }
    }
}

#endif
#endif
