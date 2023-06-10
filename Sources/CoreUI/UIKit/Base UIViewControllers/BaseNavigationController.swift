//
//  BaseNavigationController.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

// MARK: - BaseNavigationController

@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 12.0, *)
open class BaseNavigationController : UINavigationController, PresentableController {
    
    // MARK: - PresentableController
    
    public var presentedMode: PresentationMode = .default
    public var presentationManager: UIViewControllerTransitioningDelegate?
    public var currentFlowInitialController: PresentableController?
    public var prefersLargeTitles: Bool = true
    public var tintStyle: TintStyle = .default
    public var translucentStyle: TranslucentStyle = .default
    
    // MARK: - Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.applyNavigationBarStyles()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            self.applyNavigationBarStyles()
        }
    }
    
    // MARK: - Init
    
    convenience init(
        rootViewController: UIViewController,
        prefersLargeTitles: Bool = true,
        tintStyle: TintStyle = .default,
        translucentStyle: TranslucentStyle = .default
    ) {
        self.init(rootViewController: rootViewController)
        
        self.tintStyle = tintStyle
        self.translucentStyle = translucentStyle
        
        self.applyNavigationBarStyles()
    }
    
    // MARK: - TranslucentStyle
    
    public enum TranslucentStyle {
        
        /// Default style is `false`.
        case `default`
        
        case isTranslucent(_ isTranslucent: Bool)
        
        var isTranslucent: Bool {
            switch self {
            case .isTranslucent(let isTranslucent):
                return isTranslucent
            case .default:
                return false
            }
        }
    }
    
    // MARK: - TintStyle
    
    public enum TintStyle {
        
        /// System default.
        case `default`
        
        /// Transparent bar style.
        case transparent
        
        /// Color tinted bar style.
        case tinted(color: UIColor)
        
        var barTintColor: UIColor? {
            switch self {
            case .transparent:
                return .clear
            default:
                return nil
            }
        }
        
        var tintColor: UIColor {
            switch self {
            case .transparent:
                return .clear
            case .tinted(color: let color):
                return color
            default:
                if #available(iOS 13.0, *) {
                    return UIColor.systemBackground
                } else {
                    return .white
                }
            }
        }
    }
    
    private func applyNavigationBarStyles() {
        
        self.navigationBar.prefersLargeTitles = self.prefersLargeTitles
        
        // Set tint style
        let tintStyle = self.tintStyle
        self.navigationBar.barTintColor = tintStyle.barTintColor
        self.navigationBar.tintColor = tintStyle.tintColor
        
        // Set translucent style
        let isTranslucent = self.translucentStyle.isTranslucent
        self.navigationBar.isTranslucent = isTranslucent
        if isTranslucent {
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.backgroundColor = .clear
        }
        
        // Update the status bar
        self.setNeedsStatusBarAppearanceUpdate()
    }
}

#endif
#endif
