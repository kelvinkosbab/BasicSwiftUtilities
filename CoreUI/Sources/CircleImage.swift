//
//  CircleImage.swift
//
//  Copyright © Kozinga. All rights reserved.
//

public import SwiftUI

// MARK: - CircleImage

/// A view that displays an image clipped to a circle.
///
/// ```swift
/// CircleImage(systemName: "person.fill")
/// CircleImage(image: Image("avatar"))
///
/// // Mark a purely-decorative icon so VoiceOver skips over it:
/// CircleImage(systemName: "circle.fill", decorative: true)
/// ```
public struct CircleImage: View {

    let image: Image
    let isDecorative: Bool

    /// Creates a circle image from a system symbol name.
    ///
    /// - Parameter systemName: The name of the SF Symbol to display.
    /// - Parameter decorative: If `true`, the image is hidden from VoiceOver
    ///   and the accessibility tree. Use this for purely-decorative icons that
    ///   carry no meaning (e.g., visual padding, background decoration).
    ///   Defaults to `false`.
    public init(systemName: String, decorative: Bool = false) {
        self.image = Image(systemName: systemName)
        self.isDecorative = decorative
    }

    /// Creates a circle image from an existing `Image`.
    ///
    /// - Parameter image: The image to display.
    /// - Parameter decorative: If `true`, the image is hidden from VoiceOver
    ///   and the accessibility tree. Defaults to `false`.
    public init(image: Image, decorative: Bool = false) {
        self.image = image
        self.isDecorative = decorative
    }

    public var body: some View {
        self.image
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .accessibilityHidden(self.isDecorative)
    }
}

// MARK: - Previews

#Preview("CircleImage — system symbols") {
    HStack(spacing: Spacing.base) {
        CircleImage(systemName: "person.fill")
            .frame(width: 48, height: 48)
            .foregroundStyle(.blue)

        CircleImage(systemName: "heart.fill")
            .frame(width: 48, height: 48)
            .foregroundStyle(.red)

        CircleImage(systemName: "star.fill")
            .frame(width: 48, height: 48)
            .foregroundStyle(.yellow)

        CircleImage(systemName: "checkmark")
            .frame(width: 48, height: 48)
            .foregroundStyle(.green)
    }
    .padding()
}

#Preview("CircleImage — sizes") {
    HStack(alignment: .center, spacing: Spacing.base) {
        CircleImage(systemName: "person.fill")
            .frame(width: 24, height: 24)
            .foregroundStyle(.indigo)

        CircleImage(systemName: "person.fill")
            .frame(width: 48, height: 48)
            .foregroundStyle(.indigo)

        CircleImage(systemName: "person.fill")
            .frame(width: 96, height: 96)
            .foregroundStyle(.indigo)
    }
    .padding()
}

#Preview("CircleImage — decorative variant") {
    VStack(alignment: .leading, spacing: Spacing.base) {
        Label {
            Text("Default — VoiceOver reads this image")
        } icon: {
            CircleImage(systemName: "info.circle.fill")
                .frame(width: 24, height: 24)
                .foregroundStyle(.blue)
        }

        Label {
            Text("Decorative — VoiceOver skips this image")
        } icon: {
            CircleImage(systemName: "info.circle.fill", decorative: true)
                .frame(width: 24, height: 24)
                .foregroundStyle(.blue)
        }
    }
    .padding()
}
