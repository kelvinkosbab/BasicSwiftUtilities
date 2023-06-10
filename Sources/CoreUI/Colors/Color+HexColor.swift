//
//  File.swift
//  
//
//  Created by Kelvin Kosbab on 6/1/23.
//

import SwiftUI

// MARK: - SwiftUI Color

@available(iOS 13.0, macOS 11, tvOS 13.0, watchOS 6.0, *)
public extension Color {

    /// Reutrns an color defined by it's hex value.
    ///
    /// Example:
    /// ```swift
    /// ZStack {
    ///     Color.halo(.core900)
    ///     Image(systemName: "sun.max.fill")
    ///         .foregroundStyle(.hex(0x5B2071)) // For hex color code "#5B2071"
    /// }
    /// .frame(width: 200, height: 100)
    /// ```
    ///
    /// Note: A color used as a view expands to fill all the space it’s given, as defined by the frame of the
    /// enclosing ZStack in the above example.
    ///
    /// - Parameter hex: The hex value in hexadecimal. For example `0x5B2071`.
    /// - Parameter opacity: An optional degree of opacity, given in the range `0` to
    ///     `1`. A value of `0` means 100% transparency, while a value of `1`
    ///     means 100% opacity. The default is `1`.
    static func hex(
        _ hex: Int,
        opacity: Double = 1
    ) -> Color {
        let color = HexColor(hex: hex)
        return Color(
            red: color.red,
            green: color.green,
            blue: color.blue,
            opacity: opacity
        )
    }
}
