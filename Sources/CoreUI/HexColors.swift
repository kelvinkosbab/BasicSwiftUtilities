//
//  HexColors.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import UIKit
import SwiftUI

// MARK: - RGBColor

/// A representation of a color represented by its RGB Value..
protocol RGBColor {
 
    /// The amount of red in the color.
    var red: Double { get }
 
    /// The amount of green in the color.
    var green: Double { get }
 
    /// The amount of red in the color.
    var blue: Double { get }
}

// MARK: - HexColor
 
/// A representation of a color represented by its hexadecimal value.
///
/// [Apple's SwiftUI Color documentation.](https://developer.apple.com/documentation/swiftui/color)
struct HexColor: RGBColor {
 
    /// A representation of a color represented by its hexadecimal value.
    let hexValue: Int
    
    /// Constructs a `HexColor`.
    ///
    /// Example:
    /// ```
    /// let color = Color(hex: 0x44DAA7) // For hex color code "#44DAA7"
    /// ```
    public init(hex: Int) {
        self.hexValue = hex
    }
    
    /// Constructs a `HexColor` from a String hex value.
    ///
    /// Example:
    /// ```
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

    #if DEBUG
    
    /// Uppercased string representation of hex color.
    ///
    /// Marked internal for internal testing.
    var hexString: String {
        return String(self.hexValue, radix: 16).uppercased()
 
    }
    
    #endif
}
 
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
    static func hex(_ hex: Int, opacity: Double = 1) -> Color {
        let color = HexColor(hex: hex)
        return Color(red: color.red,
                     green: color.green,
                     blue: color.blue,
                     opacity: opacity)
    }
}

// MARK: - UIKit Color

public extension UIColor {

    /// Reutrns an color defined by it's hex value.
    ///
    /// Example usage:
    /// ```swift
    /// let view = UIView()
    /// view.backgroundColor = .hex(0x5B2071) // For hex color code "#5B2071"
    /// ```
    ///
    /// - Parameter hex: The hex value in hexadecimal. For example `0x44DAA7`.
    /// - Parameter alpha: An optional degree of opacity, given in the range `0` to
    ///     `1`. A value of `0` means 100% transparency, while a value of `1`
    ///     means 100% opacity. The default is `1`.
    static func hex(_ hex: Int, opacity: Double = 1) -> UIColor {
        let color = HexColor(hex: hex)
        return UIColor(red: color.red,
                       green: color.green,
                       blue: color.blue,
                       alpha: opacity)
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 11, tvOS 13.0, watchOS 6.0, *)
struct Color_Previews: PreviewProvider {
 
    /// In order to preview UIKit views / fonts in a `PreviewProvider` we must use
    /// `UIViewRepresentable`. This protocol can map a UIKit object into a SwiftUI View.
    struct UIKitView: UIViewRepresentable {
 
        typealias UIViewType = UIView
 
        let hex: Int
 
        func makeUIView(context: UIViewRepresentableContext<UIKitView>) -> UIView {
 
            // Create and configure the UILabel.
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .hex(self.hex)
            return view
        }
 
        func updateUIView(_ uiView: UIView, context: Context) {
            // do nothing
        }
    }
    
    static var mockHexColors: [Int] = [
        0x8250C4,
        0x5ECBC8,
        0x438FFF,
        0xEB5757,
        0x5B2071,
        0xEC5A96,
        0x73B761,
        0x4A588A,
        0xECC846,
        0x8D6FD1,
        0x95DABB,
        0x374649,
        0xFD625E,
        0xF2C80F,
        0x5F6B6D,
        0x8AD4EB,
        0xA66999,
        0x4A8DDC,
        0xF3C911,
        0xDC5B57,
        0x33AE81,
        0x95C8F0,
        0xDD915F,
        0x074650,
        0x009292,
        0xFE6DB6,
        0x480091,
        0xB66DFF,
        0xB5DAFE,
        0x118DFF,
        0xB73A3A,
        0x118DFF,
        0x750985,
        0xC83D95,
        0x1DD5EE,
        0x3049AD,
        0x325748,
        0x37A794,
        0x8B3D88,
        0xDD6B7F,
        0x77C4A8,
        0x426871,
        0xD2B04C,
        0x998F85,
        0xFFA500,
        0x107C10,
        0x499195,
        0x00ACFC,
        0xF18F49,
        0x326633,
        0xF1C716,
        0xD8D7BF,
        0xE87200,
        0xE13102,
        0xD3004C,
        0x9B0065,
        0x7D0033,
        0x5C0001,
        0x8BC7F7,
        0x46B3F3,
        0x0078ED,
        0x0050FB,
        0x064168,
        0x3049AD,
        0xC83D95,
        0x262476,
        0x234990,
        0x2F8AC3,
        0xFFC1CB,
        0xAE3535,
        0x094782,
        0x54B5FB,
        0x71C0A7,
        0x478F48,
        0x326633,
        0xF17925,
        0x004753,
        0xCCAA14,
        0xD82C20
    ]
 
    static var previews: some View {
        List {
            ForEach(self.mockHexColors, id: \.self) { hex in
                HStack {
                    Text("\(HexColor(hex: hex).hexString)")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                    Rectangle()
                        .foregroundColor(.hex(hex))
                }
            }
        }
        .previewDisplayName("SwiftUI and Color")
 
        List {
            ForEach(self.mockHexColors, id: \.self) { hex in
                HStack {
                    Text("\(HexColor(hex: hex).hexString)")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                    UIKitView(hex: hex)
                }
            }
        }
        .previewDisplayName("UIKit and UIColor")
    }
}
 
#endif
