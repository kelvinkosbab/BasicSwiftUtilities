//
//  UIViewController+ChildViewController.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

// MARK: - UIViewController

public extension UIViewController {

    // MARK: - Child View Controller

    /// Adds a view controller as a child and mounts the child view in the provided container view.
    ///
    /// - Parameter childViewController: View controller to add as a child.
    /// - Parameter containerView: View to add the child view controller's view to.
    /// - Parameter relativeLayoutType: How the child view should be layed out in the `containerView`. Default is `.view`.
    @available(iOS 11.0, *)
    func add(
        childViewController: UIViewController,
        intoContainerView containerView: UIView,
        relativeLayoutType: RelativeLayoutType = .view
    ) {
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(childViewController)
        childViewController.view.frame = containerView.bounds
        childViewController.view.addToContainer(containerView, relativeLayoutType: relativeLayoutType)
        childViewController.didMove(toParent: self)
    }

    /// Adds a view controller as a child and mounts the child view into `self.view`.
    ///
    /// - Parameter childViewController: View controller to add as a child.
    /// - Parameter relativeLayoutType: How the child view should be layed out in the `containerView`. Default is `.view`.
    @available(iOS 11.0, *)
    func add(
        childViewController: UIViewController,
        relativeLayoutType: RelativeLayoutType = .view
    ) {
        self.add(
            childViewController: childViewController,
            intoContainerView: self.view,
            relativeLayoutType: relativeLayoutType
        )
    }

    /// Removes the provided view controller from its partent view controller.
    ///
    /// - Parameter childViewController: View controller to remove.
    func remove(childViewController: UIViewController) {
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }

    // MARK: - Top View Controller

    /// Returns the view controller that at the top of the app.
    var topPresentedController: UIViewController {
        var topViewController = self
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }

        // Check for UITabBarController
        if let tabBarController = topViewController as? UITabBarController,
            let selectedViewController = tabBarController.viewControllers?[tabBarController.selectedIndex] {
            topViewController = selectedViewController.topPresentedController
        }

        // Check for UINavigationBarController
        if let navigationController = topViewController as? UINavigationController,
           let lastViewController = navigationController.viewControllers.last {
            topViewController = lastViewController.topPresentedController
        }

        return topViewController
    }
}

#endif
#endif
