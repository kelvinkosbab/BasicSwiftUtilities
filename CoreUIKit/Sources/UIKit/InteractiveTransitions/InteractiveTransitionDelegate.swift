//
//  InteractiveTransitionDelegate.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(tvOS)
#if !os(watchOS)
#if !os(visionOS)

public import UIKit

// MARK: - InteractiveTransitionDelegate

public protocol InteractiveTransitionDelegate: AnyObject {
    func interactionDidSurpassThreshold(_ interactiveTransition: InteractiveTransition)
}

#endif
#endif
#endif
#endif
