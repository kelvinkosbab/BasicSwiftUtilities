//
//  PresentableOption.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import UIKit

// MARK: - PresentableOption

public enum PresentableOption {
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
