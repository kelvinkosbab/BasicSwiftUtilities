//
//  BaseNavigationController.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import UIKit

// MARK: - BaseNavigationController

open class BaseNavigationController : UINavigationController, PresentableController {
    
    // MARK: - PresentableController
    
    public var presentedMode: PresentationMode = .default
    public var presentationManager: UIViewControllerTransitioningDelegate?
    public var currentFlowInitialController: PresentableController?
    public var tintColor: UIColor = AppColors.appTintUIColor
    
    // MARK: - Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationBar.prefersLargeTitles = true
        }
        self.applyNavigationBarStyles()
    }
    
    // MARK: - Init
    
    convenience init(rootViewController: UIViewController,
                     navigationBarStyle: NavigationBarStyle,
                     tintColor: UIColor = AppColors.appTintUIColor) {
        self.init(rootViewController: rootViewController)
        
        self.navigationBarStyle = navigationBarStyle
        self.tintColor = tintColor
        self.applyNavigationBarStyles()
    }
    
    // MARK: - NavigationBarStyle
    
    public enum NavigationBarStyle {
        
        case `default`
        case transparent
        
        var isTranslucent: Bool {
            switch self {
            case .default, .transparent:
                return true
            }
        }
        
        var barTintColor: UIColor? {
            switch self {
            case .default:
                return nil
            case .transparent:
                return .clear
            }
        }
        
        var tintColor: UIColor {
            switch self {
            case .default:
                return self.tintColor
            case .transparent:
                return .white
            }
        }
        
        var titleTextAttributes: [NSAttributedString.Key : Any]? {
            return [ .font: UIFont.bodyBold ]
        }
        
        var largeTitleTextAttributes: [NSAttributedString.Key : Any]? {
            return [ .font: UIFont.titleBold]
        }
        
        var backIndicator: UIImage? {
            switch self {
            default:
                return nil
            }
        }
        
        var backItemTitle: String {
            switch self {
            default:
                return ""
            }
        }
    }
    
    public var navigationBarStyle: NavigationBarStyle? {
        didSet {
            if self.navigationBarStyle != oldValue {
                self.applyNavigationBarStyles()
            }
        }
    }
    
    private func applyNavigationBarStyles() {
        
        let navigationBarStyle = self.navigationBarStyle ?? .default
        
        // Title and tint
        self.navigationBar.barTintColor = navigationBarStyle.barTintColor
        self.navigationBar.tintColor = navigationBarStyle.tintColor
        self.navigationBar.isTranslucent = navigationBarStyle.isTranslucent
        self.navigationBar.titleTextAttributes = navigationBarStyle.titleTextAttributes
        if #available(iOS 11.0, *) {
            self.navigationBar.largeTitleTextAttributes = navigationBarStyle.largeTitleTextAttributes
        }
        
        switch navigationBarStyle {
        case .transparent:
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.backgroundColor = .clear
        default: break
        }
        
        // Update the status bar
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Status Bar Style
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        switch self.navigationBarStyle ?? .default {
        case .default:
            return .default
        case .transparent:
            return .lightContent
        }
    }
}
