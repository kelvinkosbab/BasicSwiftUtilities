//
//  InteractiveTransitionDelegate.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import UIKit

// MARK: - InteractiveTransitionDelegate

public protocol InteractiveTransitionDelegate : AnyObject {
    func interactionDidSurpassThreshold(_ interactiveTransition: InteractiveTransition)
}

#endif
