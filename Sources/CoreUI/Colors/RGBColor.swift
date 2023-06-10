//
//  RGBColor.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - RGBColor

/// A representation of a color represented by its RGB Value.
protocol RGBColor {
 
    /// The amount of red in the color.
    var red: Double { get }
 
    /// The amount of green in the color.
    var green: Double { get }
 
    /// The amount of red in the color.
    var blue: Double { get }
}
