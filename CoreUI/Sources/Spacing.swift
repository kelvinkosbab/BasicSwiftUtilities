//
//  Spacing.swift
//
//  Copyright © Kozinga. All rights reserved.
//

public import SwiftUI

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
public enum Spacing {
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

// MARK: - Previews

/// A single row of the spacing ruler — a labeled bar whose width matches the
/// spacing constant it represents.
private struct SpacingRulerRow: View {
    let name: String
    let value: CGFloat

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.base) {
            Text(name)
                .font(.system(.body, design: .monospaced))
                .frame(width: 60, alignment: .leading)

            Text("\(Int(value))pt")
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)

            RoundedRectangle(cornerRadius: 2)
                .fill(.tint)
                .frame(width: value, height: 16)

            Spacer()
        }
    }
}

#Preview("Spacing scale") {
    VStack(alignment: .leading, spacing: Spacing.small) {
        Text("Spacing scale")
            .font(.headline)

        SpacingRulerRow(name: "tiny", value: Spacing.tiny)
        SpacingRulerRow(name: "small", value: Spacing.small)
        SpacingRulerRow(name: "base", value: Spacing.base)
        SpacingRulerRow(name: "large", value: Spacing.large)
        SpacingRulerRow(name: "xl", value: Spacing.xl)
        SpacingRulerRow(name: "xxl", value: Spacing.xxl)
    }
    .padding()
}
