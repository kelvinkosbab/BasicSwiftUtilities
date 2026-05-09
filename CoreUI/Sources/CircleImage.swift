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
