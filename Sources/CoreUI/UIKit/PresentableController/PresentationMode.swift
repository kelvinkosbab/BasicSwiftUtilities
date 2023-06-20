//
//  PresentationMode.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

// MARRK: - PresentationMode

@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 12.0, tvOS 12.0, *)
public enum PresentationMode {
    
    public static let `default`: PresentationMode = .formSheet
    
    case modal(
        presentationStyle: UIModalPresentationStyle,
        transitionStyle: UIModalTransitionStyle
    )
    
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
#endif
