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
/// ```
public struct CircleImage: View {

    let image: Image

    /// Creates a circle image from a system symbol name.
    ///
    /// - Parameter systemName: The name of the SF Symbol to display.
    public init(systemName: String) {
        self.image = Image(systemName: systemName)
    }

    /// Creates a circle image from an existing `Image`.
    ///
    /// - Parameter image: The image to display.
    public init(image: Image) {
        self.image = image
    }

    public var body: some View {
        self.image
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
    }
}
