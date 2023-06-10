//
//  UIViewController+Util.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

// MARK: - StoryboardViewController

public protocol StoryboardViewController {
    
    static func newViewController(fromStoryboard storyboard: UIStoryboard) -> Self
    static func newViewController(fromStoryboardWithName storyboardName: String,
                                  bundle: Bundle) -> Self
    static func newViewController(fromStoryboardWithName storyboardName: String) -> Self
}

public extension StoryboardViewController where Self : UIViewController {
    
    static func newViewController(fromStoryboard storyboard: UIStoryboard) -> Self {
        
        // Check the storyboard for a controller with an identifier matching the name of the
        // view controller class.
        let viewControllerIdentifier = String(describing: Self.self)
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier)
        
        guard let viewController = viewController as? Self else {
            fatalError("View controller with identifier=\(viewControllerIdentifier) is not of type \(viewControllerIdentifier)")
        }
        
        return viewController
    }
    
    static func newViewController(fromStoryboardWithName storyboardName: String,
                                  bundle: Bundle) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        return self.newViewController(fromStoryboard: storyboard)
    }
    
    static func newViewController(fromStoryboardWithName storyboardName: String) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: .main)
        return self.newViewController(fromStoryboard: storyboard)
    }
}

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

#endif
#endif
