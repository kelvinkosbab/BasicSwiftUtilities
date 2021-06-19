//
//  PresentableController.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import UIKit
import Core

// MARK: - PresentableController

public protocol PresentableController : AnyObject {
    var presentedMode: PresentationMode { get set }
    var presentationManager: UIViewControllerTransitioningDelegate? { get set }
    var currentFlowInitialController: PresentableController? { get set }
    func dismissController(completion: (() -> Void)?)
    func dismissCurrentNavigationFlow(completion: (() -> Void)?)
}

public extension PresentableController where Self : UIViewController {
    
    private var logger: Logger {
        return Logger(subsystem: "CoreUI.PresentableController", category: "PresentableController")
    }
    
    func presentIn(_ presentingViewController: UIViewController,
                   withMode mode: PresentationMode,
                   options: [PresentableOption] = []) {
        
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
            presentingViewController.present(viewControllerToPresent, animated: true, completion: nil)
            
        case .formSheet:
            self.presentIn(presentingViewController,
                           withMode: .modal(presentationStyle: .formSheet, transitionStyle: .coverVertical),
                           options: options)
            
        case .modal(let presentationStyle, let transitionStyle):
            viewControllerToPresent.modalPresentationStyle = presentationStyle
            viewControllerToPresent.modalTransitionStyle = transitionStyle
            viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
            presentingViewController.present(viewControllerToPresent, animated: true, completion: nil)
            
        case .show:
            let viewControllerToPresent = BaseNavigationController(rootViewController: self)
            if presentingViewController.splitViewController == nil, let navigationController = presentingViewController.navigationController {
                navigationController.pushViewController(self, animated: true)
            } else {
                presentingViewController.showDetailViewController(viewControllerToPresent, sender: presentingViewController)
            }
        }
    }
    
    func dismissController(completion: (() -> Void)? = nil) {
        switch self.presentedMode {
        case .show:
            
            guard let navigationController = self.navigationController,
                let index = navigationController.viewControllers.firstIndex(of: self),
                index > 0 else {
                    self.logger.error("Attempting to pop root view controller in stack")
                    return
            }
            
            // Pop to the controller before this one
            let viewControllerToPopTo = navigationController.viewControllers[index - 1]
            navigationController.popToViewController(viewControllerToPopTo, animated: true)
            
        default:
            
            guard let presentingViewController = self.presentingViewController else {
                self.logger.error("Presenting view controller not found")
                return
            }
            
            presentingViewController.dismiss(animated: true, completion: completion)
        }
    }
    
    func dismissCurrentNavigationFlow(completion: (() -> Void)? = nil) {
        
        guard let currentFlowInitialController = self.currentFlowInitialController else {
            self.dismissController(completion: completion)
            return
        }
        
        currentFlowInitialController.dismissController(completion: completion)
    }
}
