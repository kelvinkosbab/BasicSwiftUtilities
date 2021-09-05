//
//  AppFont.swift
//
//  Created by Kelvin Kosbab on 8/16/21.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// MARK: - AppFont

public struct AppFont {
    
    // MARK: - Style
    
    public enum Style {
        case systemRegular
        case systemBold
        case systemItalic
        case systemMonospace
        case custom(String)
    }
    
    public static var regular: Style = .systemRegular
    public static var bold: Style = .systemBold
    public static var italic: Style = .systemItalic
    public static var monospace: Style = .systemMonospace
    
    // MARK: - Size
    
    public struct Size {
        static let footnote: CGFloat = 13
        static let body: CGFloat = 16
        static let heading: CGFloat = 20
        static let title: CGFloat = 28
        static let xlTitle: CGFloat = 70
    }
}
