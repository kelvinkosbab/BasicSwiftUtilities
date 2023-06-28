//
//  PresentableController.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(tvOS)
#if !os(watchOS)

import UIKit

// MARK: - PresentableController

/// Defines a protocol to help present, manage, and dismiss view controllers. This protocol should only be applied
/// to a `UIViewController` type.
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 12.0, tvOS 12.0, *)
public protocol PresentableController : AnyObject {
    
    /// How the current controller was initially presented.
    ///
    /// For supported modes see ``PresentationMode``.
    var presentedMode: PresentationMode { get set }
    
    /// Reference to the transition delegate.
    var presentationManager: UIViewControllerTransitioningDelegate? { get set }
    
    /// Reference of the initial view controller that was presented in the current flow. This helps for dismissing
    /// many related view controllers if desired. For example, dismissing a modal navigation controller to set up a new
    /// capabilitiy.
    var currentFlowInitialController: PresentableController? { get set }
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 12.0, tvOS 12.0, *)
public extension PresentableController where Self : UIViewController {
    
    // MARK: - PresentIn
    
    /// Present the provided view controller.
    ///
    /// - Parameter mode: How the view controller will be presented.
    /// - Parameter options: Presentation options for the presentation.
    /// - Parameter completion: Handler which is called when the presentation has been completed.
    func presentIn(
        _ presentingViewController: UIViewController,
        withMode mode: PresentationMode,
        options: [PresentableOption] = [],
        completion: (() -> Void)? = nil
    ) {
        // Configure the view controller to present
        let viewControllerToPresent: UIViewController = {
            if options.inNavigationController {
                return BaseNavigationController(rootViewController: self)
            } else {
                return self
            }
        }()
        
        // Configure the initial flow controller
        self.presentedMode = mode
        if !mode.isShow {
            self.currentFlowInitialController = self
        }
        
        // Present the controller
        switch mode {
        case .crossDissolve:
            viewControllerToPresent.modalPresentationStyle = .overCurrentContext
            viewControllerToPresent.modalTransitionStyle = .crossDissolve
            viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
            presentingViewController.present(viewControllerToPresent, animated: true, completion: completion)
            
        case .formSheet:
            self.presentIn(
                presentingViewController,
                withMode: .modal(presentationStyle: .formSheet, transitionStyle: .coverVertical),
                options: options
            )
            
        case .modal(let presentationStyle, let transitionStyle):
            viewControllerToPresent.modalPresentationStyle = presentationStyle
            viewControllerToPresent.modalTransitionStyle = transitionStyle
            viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
            presentingViewController.present(viewControllerToPresent, animated: true, completion: completion)
            
        case .show:
            let viewControllerToPresent = BaseNavigationController(rootViewController: self)
            if presentingViewController.splitViewController == nil,
               let navigationController = presentingViewController.navigationController {
                navigationController.pushViewController(self, animated: true) {
                    completion?()
                }
            } else if let splitViewController = presentingViewController.splitViewController {
                splitViewController.showDetailViewController(viewControllerToPresent, sender: presentingViewController)
                completion?()
            }
        }
    }
    
    /// Asyncronously present the provided view controller.
    ///
    /// - Parameter mode: How the view controller will be presented.
    /// - Parameter options: Presentation options for the presentation.
    @available(iOS 13.0.0, *)
    func presentIn(
        _ presentingViewController: UIViewController,
        withMode mode: PresentationMode,
        options: [PresentableOption] = []
    ) async {
        await withCheckedContinuation { continuation in
            self.presentIn(
                presentingViewController,
                withMode: mode,
                options: options
            ) {
                continuation.resume()
            }
        }
    }
    
    // MARK: - DismissController
    
    /// Dismisses the current controller.
    ///
    /// - Parameter completion: Hander which is executed after the controller has dismissed.
    func dismissController(completion: (() -> Void)? = nil) {
        switch self.presentedMode {
        case .show:
            
            guard let navigationController = self.navigationController,
                let index = navigationController.viewControllers.firstIndex(of: self),
                index > 0 else {
                    return
            }
            
            // Pop to the controller before this one
            let viewControllerToPopTo = navigationController.viewControllers[index - 1]
            navigationController.pop(to: viewControllerToPopTo, animated: true) {
                completion?()
            }
            
        default:
            
            guard let presentingViewController = self.presentingViewController else {
                return
            }
            
            presentingViewController.dismiss(animated: true, completion: completion)
        }
    }
    
    /// Dismisses the current controller.
    @available(iOS 13.0.0, *)
    func dismissController() async {
        await withCheckedContinuation { continuation in
            self.dismissController {
                continuation.resume()
            }
        }
    }
}

#endif
#endif
#endif
