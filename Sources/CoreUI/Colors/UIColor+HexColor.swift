//
//  UIColor+HexColor.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import UIKit

// MARK: - UIKit Color

@available(macOS, unavailable)
public extension UIColor {

    /// Reutrns an color defined by it's hex value.
    ///
    /// Example usage:
    /// ```swift
    /// let view = UIView()
    /// view.backgroundColor = .hex(0x5B2071) // For hex "#5B2071"
    /// ```
    ///
    /// - Parameter hex: The hex value in hexadecimal. For example `0x44DAA7`.
    /// - Parameter alpha: An optional degree of opacity, given in the range `0` to
    ///     `1`. A value of `0` means 100% transparency, while a value of `1`
    ///     means 100% opacity. The default is `1`.
    static func hex(
        _ hex: Int,
        opacity: Double = 1
    ) -> UIColor {
        let color = HexColor(hex: hex)
        return UIColor(
            red: color.red,
            green: color.green,
            blue: color.blue,
            alpha: opacity
        )
    }
}

#endif
