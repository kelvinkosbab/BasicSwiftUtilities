//
//  PresentationMode.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

#if !os(macOS)

import UIKit

// MARRK: - PresentationMode

public enum PresentationMode {
    
    public static let `default`: PresentationMode = .formSheet
    
    case modal(presentationStyle: UIModalPresentationStyle, transitionStyle: UIModalTransitionStyle)
    case crossDissolve
    case formSheet
    case show
    
    var isShow: Bool {
        switch self {
        case .show:
            return true
        default:
            return false
        }
    }
}

#endif
