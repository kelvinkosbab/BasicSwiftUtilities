//
//  File.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

public extension UINavigationController {
    
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        self.pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = self.transitionCoordinator else {
            completion()
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    @available(iOS 13.0.0, *)
    func push(viewController: UIViewController, animated: Bool) async {
        await withCheckedContinuation { continuation in
            self.pushViewController(viewController,
                                    animated: animated) {
                continuation.resume()
            }
        }
    }
    
    func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        self.popToRootViewController(animated: animated)
        
        guard animated, let coordinator = self.transitionCoordinator else {
            completion()
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    @available(iOS 13.0.0, *)
    func popToRootViewController(animated: Bool) async {
        await withCheckedContinuation { continuation in
            self.popToRootViewController(animated: animated) {
                continuation.resume()
            }
        }
    }
}

#endif
#endif
