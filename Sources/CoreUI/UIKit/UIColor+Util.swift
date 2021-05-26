//
//  UIColor+Util.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import UIKit

// MARK: - UIColor

public extension UIColor {
    
    // MARK: - Hue / Saturation / Brightness / Alpha
    
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
    
    var rgbValue: UInt32? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
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
    
    static func rgbColor(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) -> UIColor {
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
    
    var hex: String {
        var rFloat: CGFloat = 0.0
        var gFloat: CGFloat = 0.0
        var bFloat: CGFloat = 0.0
        var aFloat: CGFloat = 0.0
        self.getRed(&rFloat, green: &gFloat, blue: &bFloat, alpha: &aFloat)
        let r = (Int)(255.0 * rFloat)
        let g = (Int)(255.0 * gFloat)
        let b = (Int)(255.0 * bFloat)
        _ = (Int)(255.0 * aFloat); // alpha
        let hex = String(format: "%02x%02x%02x", r, g, b)
        return hex
    }
    
    static func color(hash: Int) -> UIColor {
        let red = Double((hash >> 16) & 0xFF) / 255.0
        let green = Double((hash >> 8) & 0xFF) / 255.0
        let blue = Double(hash & 0xFF) / 255.0
        return UIColor(red: CGFloat(red),
                       green:CGFloat(green),
                       blue: CGFloat(blue),
                       alpha: CGFloat(1.0))
    }
    
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString = String((cString as NSString).substring(from: 1))
        }
        
        // Check if valid hex string
        guard cString.count == 6 else {
            return nil
        }
        
        // Valid hex string
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}
