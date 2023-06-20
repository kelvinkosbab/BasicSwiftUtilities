//
//  InteractiveTransitionDelegate.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

// MARK: - InteractiveTransitionDelegate

public protocol InteractiveTransitionDelegate : AnyObject {
    func interactionDidSurpassThreshold(_ interactiveTransition: InteractiveTransition)
}

#endif
#endif
