//
//  PresentableController.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

#if !os(macOS)

import UIKit
import Core

// MARK: - PresentableController

public protocol PresentableController : AnyObject {
    var presentedMode: PresentationMode { get set }
    var presentationManager: UIViewControllerTransitioningDelegate? { get set }
    var currentFlowInitialController: PresentableController? { get set }
}

public extension PresentableController where Self : UIViewController {
    
    // MARK: - PresentIn
    
    func presentIn(_ presentingViewController: UIViewController,
                   withMode mode: PresentationMode,
                   options: [PresentableOption] = [],
                   completion: (() -> Void)? = nil) {
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
            self.presentIn(presentingViewController,
                           withMode: .modal(presentationStyle: .formSheet, transitionStyle: .coverVertical),
                           options: options)
            
        case .modal(let presentationStyle, let transitionStyle):
            viewControllerToPresent.modalPresentationStyle = presentationStyle
            viewControllerToPresent.modalTransitionStyle = transitionStyle
            viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
            presentingViewController.present(viewControllerToPresent, animated: true, completion: completion)
            
        case .show:
            let viewControllerToPresent = BaseNavigationController(rootViewController: self)
            if presentingViewController.splitViewController == nil, let navigationController = presentingViewController.navigationController {
                navigationController.pushViewController(self, animated: true) {
                    completion?()
                }
            } else if let splitViewController = presentingViewController.splitViewController {
                splitViewController.showDetailViewController(viewControllerToPresent, sender: presentingViewController)
                completion?()
            }
        }
    }
    
    @available(iOS 13.0.0, *)
    func presentIn(_ presentingViewController: UIViewController,
                   withMode mode: PresentationMode,
                   options: [PresentableOption] = []) async {
        await withCheckedContinuation { continuation in
            self.presentIn(presentingViewController,
                           withMode: mode,
                           options: options) {
                continuation.resume()
            }
        }
    }
    
    // MARK: - DismissController
    
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
            navigationController.popToViewController(viewControllerToPopTo, animated: true)
            completion?()
            
        default:
            
            guard let presentingViewController = self.presentingViewController else {
                return
            }
            
            presentingViewController.dismiss(animated: true, completion: completion)
        }
    }
    
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
