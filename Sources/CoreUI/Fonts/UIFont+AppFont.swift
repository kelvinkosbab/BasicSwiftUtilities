//
//  UIFont+AppFont.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// MARK: - UIFont

public extension UIFont {
    
    static func getAppFont(_ style: AppFont.Style,
                           size: CGFloat) -> UIFont {
        switch style {
        case .systemRegular:
            return UIFont.systemFont(ofSize: size)
            
        case .systemBold:
            return UIFont.boldSystemFont(ofSize: size)
            
        case .systemItalic:
            return UIFont.italicSystemFont(ofSize: size)
            
        case .custom(fontName: let fontName):
            if let font = UIFont(name: fontName,
                                  size: size) {
                return font
            } else {
                return self.getAppFont(.systemRegular,
                                  size: AppFont.Size.body)
            }
            
        case .systemMonospace:
            if #available(iOS 13.0, *) {
                return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
            } else {
                fatalError("Monospace not supported")
            }
        }
    }
}
