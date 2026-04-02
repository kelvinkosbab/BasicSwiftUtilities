//
//  StoryboardViewController.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

// MARK: - StoryboardViewController

/// Defines mechanisms for creating a new view controller from a `Storyboard`.
public protocol StoryboardViewController {

    /// Create a new view controller from a storybaord with the same name as the `UIViewController`.
    ///
    /// - Parameter storyboard: The `Storyboard` which the view controller exists in.
    static func newViewController(fromStoryboard storyboard: UIStoryboard) -> Self

    /// Create a new view controller from a storybaord with the same name as the `UIViewController`.
    ///
    /// - Parameter storyboardName: The name of the `Storyboard` which the view controller exists in.
    static func newViewController(fromStoryboardWithName storyboardName: String) -> Self

    /// Create a new view controller from a storybaord with the same name as the `UIViewController`.
    ///
    /// - Parameter storyboardName: The name of the `Storyboard` which the view controller exists in.
    /// - Parameter bundle: The `Bundle` in which the `Storyboard` exists in. Default is `.main`.
    static func newViewController(
        fromStoryboardWithName storyboardName: String,
        bundle: Bundle
    ) -> Self
}

public extension StoryboardViewController where Self: UIViewController {

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

    static func newViewController(
        fromStoryboardWithName storyboardName: String,
        bundle: Bundle = .main
    ) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: .main)
        return self.newViewController(fromStoryboard: storyboard)
    }
}

#endif
#endif
