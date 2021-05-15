//
//  Colors.swift
//
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - UIKit

public extension UIColor {
    static let kozRed: UIColor = UIColor(red: 180 / 255, green: 4 / 255, blue: 4 / 255, alpha: 1)
    static let kozOrange: UIColor = .systemOrange
    static let kozYellow: UIColor = .systemYellow
    static let kozGreen: UIColor = .systemGreen
    static let kozBlue: UIColor = UIColor(red: 45 / 255, green: 144 / 255, blue: 226 / 255, alpha: 1)
    static let kozPurple: UIColor = .systemPurple
    static let kozGray: UIColor = .systemGray
    
    @available(iOS 13, *)
    static let kozLightGray: UIColor = .systemGray4
}

// MARK: - SwiftUI

@available(iOS 13, *)
public extension Color {
    static let darkRed: Color = Color(red: 180 / 255, green: 4 / 255, blue: 4 / 255, opacity: 1)
    static let kozOrange: Color = .orange
    static let kozYellow: Color = .yellow
    static let kozGreen: Color = .green
    static let tallyBokBlue: Color = Color(red: 45 / 255, green: 144 / 255, blue: 226 / 255, opacity: 1)
    static let kozPurple: Color = .purple
    static let kozGray: Color = .gray
}
