//
//  HexColor.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - HexColor

/// A representation of a color represented by its hexadecimal value.
///
/// For more information see [Apple's SwiftUI Color documentation.](https://developer.apple.com/documentation/swiftui/color).
struct HexColor: RGBColor {

    /// A representation of a color represented by its hexadecimal value.
    let hexValue: Int

    /// Constructs a `HexColor`.
    ///
    /// Example:
    /// ```swift
    /// let color = Color(hex: 0x44DAA7) // For hex color code "#44DAA7"
    /// ```
    public init(hex: Int) {
        self.hexValue = hex
    }

    /// Constructs a `HexColor` from a String hex value.
    ///
    /// Example:
    /// ```swift
    /// let color = Color(hex: "44DAA7") // For hex color code "#44DAA7"
    /// ```
    public init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        hexString = hexString.replacingOccurrences(of: "0x", with: "")

        guard hexString.count == 6 else {
            return nil
        }

        guard let value = Int(hexString, radix: 16) else {
            return nil
        }

        self.hexValue = value
    }

    /// The amount of red in the color.
    var red: Double {
        Double((self.hexValue >> 16) & 0xFF) / 255
    }

    /// The amount of green in the color.
    var green: Double {
        Double((self.hexValue >> 8) & 0xFF) / 255
    }

    /// The amount of red in the color.
    var blue: Double {
        Double(self.hexValue & 0xFF) / 255
    }

    /// Uppercased string representation of hex color.
    ///
    /// Marked internal for internal testing.
    var hexString: String {
        let baseString = String(self.hexValue, radix: 16)

        if baseString.count == 5 {
            return baseString.uppercased()
        }

        // Add `0` to the beginning as needed
        var adjustedString = baseString
        while adjustedString.count < 5 {
            adjustedString = "0\(adjustedString)"
        }

        return adjustedString.uppercased()

    }
}
