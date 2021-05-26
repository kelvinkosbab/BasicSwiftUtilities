//
//  InteractiveTransitionDelegate.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import UIKit

// MARK: - InteractiveTransitionDelegate

public protocol InteractiveTransitionDelegate : AnyObject {
    func interactionDidSurpassThreshold(_ interactiveTransition: InteractiveTransition)
}
