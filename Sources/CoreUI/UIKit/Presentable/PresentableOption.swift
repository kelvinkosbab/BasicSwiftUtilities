//
//  PresentableOption.swift
//  
//
//  Created by Kelvin Kosbab on 5/22/21.
//

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

