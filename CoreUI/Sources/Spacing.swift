//
//  Spacing.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - Spacing

/// A set of standard spacing constants for consistent layout across the app.
///
/// ```swift
/// VStack(spacing: Spacing.base) {
///     Text("Hello")
///     Text("World")
/// }
/// .padding(Spacing.small)
/// ```
public struct Spacing {
    /// Extra-small spacing: 4pt.
    public static let tiny: CGFloat = 4
    /// Small spacing: 8pt.
    public static let small: CGFloat = 8
    /// Base spacing: 16pt.
    public static let base: CGFloat = 16
    /// Large spacing: 24pt.
    public static let large: CGFloat = 24
    /// Extra-large spacing: 32pt.
    public static let xl: CGFloat = 32
    /// Double extra-large spacing: 40pt.
    public static let xxl: CGFloat = 40
}
