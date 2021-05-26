//
//  UITabBarController+Util.swift
//  
//
//  Created by Kelvin Kosbab on 5/23/21.
//

import UIKit

// MARK: - UITabBarController

public extension UITabBarController {
    
    func showTabBar(animated: Bool = true,
                    animating: (() -> Void)? = nil,
                    completion: (() -> Void)? = nil) {
        let tabBarFrame = self.tabBar.frame
        let heightOffset = tabBarFrame.size.height
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: { [weak self] in
            let tabBarNewY = tabBarFrame.origin.y - heightOffset
            self?.tabBar.frame = CGRect(x: tabBarFrame.origin.x, y: tabBarNewY, width: tabBarFrame.size.width, height: tabBarFrame.size.height)
            animating?()
        }, completion: { [weak self] _ in
            self?.tabBar.isUserInteractionEnabled = true
            completion?()
        })
    }
    
    func hideTabBar(animated: Bool = true,
                    animating: (() -> Void)? = nil,
                    completion: (() -> Void)? = nil) {
        self.tabBar.isUserInteractionEnabled = false
        let tabBarFrame = self.tabBar.frame
        let heightOffset = tabBarFrame.size.height
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: { [weak self] in
            let tabBarNewY = tabBarFrame.origin.y + heightOffset
            self?.tabBar.frame = CGRect(x: tabBarFrame.origin.x, y: tabBarNewY, width: tabBarFrame.size.width, height: tabBarFrame.size.height)
            animating?()
        }, completion: { _ in
            completion?()
        })
    }
}
