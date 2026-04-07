//
//  UIColor+Util.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

public import UIKit

// MARK: - UIColor

public extension UIColor {

    // MARK: - Hue / Saturation / Brightness / Alpha

    /// The hue component of this color in the HSB color space (0.0–1.0).
    var hsbHue: CGFloat {
        var hueValue: CGFloat = 0
        var saturationValue: CGFloat = 0
        var brightnessValue: CGFloat = 0
        var alphaValue: CGFloat = 0
        self.getHue(&hueValue,
                    saturation: &saturationValue,
                    brightness: &brightnessValue,
                    alpha: &alphaValue)
        return hueValue
    }

    /// The saturation component of this color in the HSB color space (0.0–1.0).
    var hsbSaturation: CGFloat {
        var hueValue: CGFloat = 0
        var saturationValue: CGFloat = 0
        var brightnessValue: CGFloat = 0
        var alphaValue: CGFloat = 0
        self.getHue(&hueValue,
                    saturation: &saturationValue,
                    brightness: &brightnessValue,
                    alpha: &alphaValue)
        return saturationValue
    }

    /// The brightness component of this color in the HSB color space (0.0–1.0).
    var hsbBrightness: CGFloat {
        var hueValue: CGFloat = 0
        var saturationValue: CGFloat = 0
        var brightnessValue: CGFloat = 0
        var alphaValue: CGFloat = 0
        self.getHue(&hueValue,
                    saturation: &saturationValue,
                    brightness: &brightnessValue,
                    alpha: &alphaValue)
        return brightnessValue
    }

    /// The alpha component of this color in the HSB color space (0.0–1.0).
    var hsbAlpha: CGFloat {
        var hueValue: CGFloat = 0
        var saturationValue: CGFloat = 0
        var brightnessValue: CGFloat = 0
        var alphaValue: CGFloat = 0
        self.getHue(&hueValue,
                    saturation: &saturationValue,
                    brightness: &brightnessValue,
                    alpha: &alphaValue)
        return alphaValue
    }

    // MARK: - RGB

    /// The packed ARGB integer representation of this color, or `nil` if RGBA extraction fails.
    var rgbValue: UInt32? {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = UInt32(fRed * 255.0)
            let iGreen = UInt32(fGreen * 255.0)
            let iBlue = UInt32(fBlue * 255.0)
            let iAlpha = UInt32(fAlpha * 255.0)

            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            return (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue

        } else {
            // Could not extract RGBA components:
            return nil
        }
    }

    /// Creates a color from 0–255 RGB component values.
    ///
    /// - Parameters:
    ///   - red: Red component (0–255).
    ///   - green: Green component (0–255).
    ///   - blue: Blue component (0–255).
    ///   - alpha: Alpha component (0.0–1.0). Default is `1`.
    static func rgbColor(
        red: Int,
        green: Int,
        blue: Int,
        alpha: CGFloat = 1
    ) -> UIColor {
        let adjustedRed: CGFloat = CGFloat(red) / 255
        let adjustedGreen: CGFloat = CGFloat(green) / 255
        let adjustedBlue: CGFloat = CGFloat(blue) / 255
        let adjustedAlpha: CGFloat = alpha
        return UIColor(red: adjustedRed,
                       green: adjustedGreen,
                       blue: adjustedBlue,
                       alpha: adjustedAlpha)
    }

    /// - Returns value between 0-255
    var rgbRed: Int {
        var redValue: CGFloat = 0.0
        var greenValue: CGFloat = 0.0
        var blueValue: CGFloat = 0.0
        var alphaValue: CGFloat = 0.0
        self.getRed(&redValue,
                    green: &greenValue,
                    blue: &blueValue,
                    alpha: &alphaValue)
        return Int(255.0 * redValue)
    }

    /// - Returns value between 0-255
    var rgbGreen: Int {
        var redValue: CGFloat = 0.0
        var greenValue: CGFloat = 0.0
        var blueValue: CGFloat = 0.0
        var alphaValue: CGFloat = 0.0
        self.getRed(&redValue,
                    green: &greenValue,
                    blue: &blueValue,
                    alpha: &alphaValue)
        return Int(255.0 * greenValue)
    }

    /// - Returns value between 0-255
    var rgbBlue: Int {
        var redValue: CGFloat = 0.0
        var greenValue: CGFloat = 0.0
        var blueValue: CGFloat = 0.0
        var alphaValue: CGFloat = 0.0
        self.getRed(&redValue,
                    green: &greenValue,
                    blue: &blueValue,
                    alpha: &alphaValue)
        return Int(255.0 * blueValue)
    }

    /// - Returns value between 0-255
    var rgbAlpha: CGFloat {
        var redValue: CGFloat = 0.0
        var greenValue: CGFloat = 0.0
        var blueValue: CGFloat = 0.0
        var alphaValue: CGFloat = 0.0
        self.getRed(&redValue,
                    green: &greenValue,
                    blue: &blueValue,
                    alpha: &alphaValue)
        return alphaValue
    }

    // MARK: - Hex

    /// The 6-character lowercase hex string representation of this color (e.g. `"ff00cc"`).
    var hex: String {
        var rFloat: CGFloat = 0.0
        var gFloat: CGFloat = 0.0
        var bFloat: CGFloat = 0.0
        var aFloat: CGFloat = 0.0
        self.getRed(&rFloat, green: &gFloat, blue: &bFloat, alpha: &aFloat)
        let r = (Int)(255.0 * rFloat)
        let g = (Int)(255.0 * gFloat)
        let b = (Int)(255.0 * bFloat)
        _ = (Int)(255.0 * aFloat) // alpha
        let hex = String(format: "%02x%02x%02x", r, g, b)
        return hex
    }

    /// Creates a color from an integer hash value by extracting RGB components.
    ///
    /// - Parameter hash: An integer whose lower 24 bits are interpreted as RGB.
    static func color(hash: Int) -> UIColor {
        let red = Double((hash >> 16) & 0xFF) / 255.0
        let green = Double((hash >> 8) & 0xFF) / 255.0
        let blue = Double(hash & 0xFF) / 255.0
        return UIColor(red: CGFloat(red),
                       green: CGFloat(green),
                       blue: CGFloat(blue),
                       alpha: CGFloat(1.0))
    }

    /// Creates a color from a 6-character hex string.
    ///
    /// - Parameters:
    ///   - hex: A hex color string (e.g. `"FF00CC"` or `"#FF00CC"`).
    ///   - alpha: Alpha component (0.0–1.0). Default is `1.0`.
    convenience init?(
        hex: String,
        alpha: CGFloat = 1.0
    ) {

        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            cString = String((cString as NSString).substring(from: 1))
        }

        // Check if valid hex string
        guard cString.count == 6 else {
            return nil
        }

        // Valid hex string
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

#endif
