//
//  File.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(tvOS)
#if !os(watchOS)

import UIKit

public extension UINavigationController {

    /// Push a view controller on top of the current `UINavigationController`.
    ///
    /// - Parameter viewController: View controller to push on the navigation stack.
    /// - Parameter animated: Whether or not the push should be animated. Default is `true`.
    /// - Parameter completion: Handler for when the push animation is completed. Default is an empty block.
    func pushViewController(
        _ viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        self.pushViewController(viewController, animated: animated)

        guard animated, let coordinator = self.transitionCoordinator else {
            completion?()
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion?() }
    }

    /// Asyncronously push a view controller on top of the current `UINavigationController`.
    ///
    /// - Parameter viewController: View controller to push on the navigation stack.
    /// - Parameter animated: Determes if the push action should be animated. Default is `true`.
    @available(iOS 13.0.0, *)
    func push(
        viewController: UIViewController,
        animated: Bool = true
    ) async {
        await withCheckedContinuation { continuation in
            self.pushViewController(
                viewController,
                animated: animated
            ) {
                continuation.resume()
            }
        }
    }

    /// Pops the navigation stack to the root view controller.
    ///
    /// - Parameter animated: Determines if the pop action should be animated. Default is `true`.
    /// - Parameter completion: Handler for when the pop animation is completed. Default is an empty block.
    func popToRootViewController(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        self.popToRootViewController(animated: animated)

        guard animated, let coordinator = self.transitionCoordinator else {
            completion?()
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion?() }
    }

    /// Asyncronously pops the navigation stack to the root view controller.
    ///
    /// - Parameter animated: Determines if the pop action should be animated. Default is `true`.
    @available(iOS 13.0.0, *)
    func popToRootViewController(animated: Bool) async {
        await withCheckedContinuation { continuation in
            self.popToRootViewController(animated: animated) {
                continuation.resume()
            }
        }
    }

    /// Pops the navigation stack to the root view controller.
    ///
    /// - Parameter viewController: View controller to pop to in the navigation stack.
    /// - Parameter animated: Determines if the pop action should be animated. Default is `true`.
    /// - Parameter completion: Handler for when the pop animation is completed. Default is an empty block.
    func pop(
        to viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {}

    /// Asyncronously pops the navigation stack to the root view controller.
    ///
    /// - Parameter viewController: View controller to pop to in the navigation stack.
    /// - Parameter animated: Determines if the pop action should be animated. Default is `true`.
    @available(iOS 13.0.0, *)
    func pop(
        to viewController: UIViewController,
        animated: Bool = true
    ) async {
        await withCheckedContinuation { continuation in
            self.pop(to: viewController, animated: animated) {
                continuation.resume()
            }
        }
    }
}

#endif
#endif
#endif
