//
//  InteractivePresentationController.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(tvOS)
#if !os(watchOS)

import UIKit

// MARK: - InteractivePresentationController

public class InteractivePresentationController : UIPresentationController {
    
    var presentationInteractiveTransition: InteractiveTransition?
    var dismissInteractiveTransition: InteractiveTransition?
    
    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
}

// MARK: - Utilities

public extension InteractivePresentationController {
    
    /// Returns all views that are interactive for presentation.
    var allPresentationInteractiveViews: [UIView] {
        var interactiveViews: [UIView] = []
        
        // Presenting view controller
        if let presentationInteractable = self.presentingViewController.topPresentedController as? PresentationInteractable, presentationInteractable.presentationInteractiveViews.count > 0 {
            interactiveViews += presentationInteractable.presentationInteractiveViews
        }
        
        // Presenting controller
        if let presentationInteractable = self as? PresentationInteractable, presentationInteractable.presentationInteractiveViews.count > 0 {
            interactiveViews += presentationInteractable.presentationInteractiveViews
        }
        
        return interactiveViews
    }
    
    /// Returns all views that are interactive for dismissal.
    var allDismissInteractiveViews: [UIView] {
        var interactiveViews: [UIView] = []
        
        // Presented view controller
        if let dismissInteractable = self.presentedViewController.topPresentedController as? DismissInteractable, dismissInteractable.dismissInteractiveViews.count > 0 {
            interactiveViews += dismissInteractable.dismissInteractiveViews
        }
        
        // Presenting controller
        if let dismissInteractable = self as? DismissInteractable, dismissInteractable.dismissInteractiveViews.count > 0 {
            interactiveViews += dismissInteractable.dismissInteractiveViews
        }
        
        return interactiveViews
    }
}

#endif
#endif
#endif
