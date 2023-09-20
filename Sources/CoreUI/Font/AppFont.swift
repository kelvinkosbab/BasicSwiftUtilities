//
//  AppFont.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// MARK: - AppFont

/// Defines ``AppFont.Size``.
public struct AppFont {
    
    // MARK: - Size
    
    /// Defines default sizes for each font style.
    public struct Size {
        static let footnote: CGFloat = 13
        static let body: CGFloat = 16
        static let heading: CGFloat = 20
        static let title: CGFloat = 28
        static let xlTitle: CGFloat = 70
    }
}
