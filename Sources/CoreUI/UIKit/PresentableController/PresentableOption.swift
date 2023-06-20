//
//  PresentableOption.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import UIKit

// MARK: - PresentableOption

/// Defines options when presenting a view controller.
public enum PresentableOption {
    
    /// Do not present the view controller in a navigation view controller.
    case withoutNavigationController
}

extension Sequence where Iterator.Element == PresentableOption {
    
    var inNavigationController: Bool {
        return !self.contains { option -> Bool in
            switch option {
            case .withoutNavigationController:
                return true
            }
        }
    }
}

#endif
