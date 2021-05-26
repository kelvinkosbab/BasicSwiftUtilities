//
//  UIViewController+Util.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import UIKit

// MARK: - UIViewController

public extension UIViewController {
    
    // MARK: - Child View Controller
    
    @available(iOS 11.0, *)
    func add(childViewController: UIViewController, intoContainerView containerView: UIView, relativeLayoutType: RelativeLayoutType = .view) {
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(childViewController)
        childViewController.view.frame = containerView.bounds
        childViewController.view.addToContainer(containerView, relativeLayoutType: relativeLayoutType)
        childViewController.didMove(toParent: self)
        
        // Check if this view is a collection view, if so need to configure it for long-press reordering
        if let collectionViewController = childViewController as? UICollectionViewController {
            collectionViewController.collectionView?.configureLongPressReordering()
        }
    }
    
    func remove(childViewController: UIViewController) {
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
    
    // MARK: - Top View Controller
    
    var topPresentedController: UIViewController {
        var topViewController = self
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        
        // Check for UITabBarController
        if let tabBarController = topViewController as? UITabBarController, let selectedViewController = tabBarController.viewControllers?[tabBarController.selectedIndex] {
            topViewController = selectedViewController.topPresentedController
        }
        
        // Check for UINavigationBarController
        if let navigationController = topViewController as? UINavigationController, let lastViewController = navigationController.viewControllers.last {
            topViewController = lastViewController.topPresentedController
        }
        
        return topViewController
    }
}
