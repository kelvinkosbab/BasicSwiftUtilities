//
//  File.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

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
    
    func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        self.popToRootViewController(animated: animated)
        
        guard animated, let coordinator = self.transitionCoordinator else {
            completion()
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}
