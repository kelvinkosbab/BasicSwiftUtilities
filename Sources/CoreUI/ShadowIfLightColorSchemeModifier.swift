//
//  ShadowIfLightColorSchemeModifier.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreShadowModifier

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public struct ShadowIfLightColorSchemeModifier : ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    public func body(content: Content) -> some View {
        if self.colorScheme == .dark {
            content
        } else {
            content
                .shadow(
                    color: self.color,
                    radius: self.radius,
                    x: self.x,
                    y: self.y
                )
        }
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// Adds a  shadow for this view only when the environment `colorScheme` is not `dark`.
    ///
    /// Use this modifier to add a shadow of a specified color behind a view.
    /// You can offset the shadow from its view independently in the horizontal
    /// and vertical dimensions using the `x` and `y` parameters. You can also
    /// blur the edges of the shadow using the `radius` parameter. Use a
    /// radius of zero to create a sharp shadow. Larger radius values produce
    /// softer shadows.
    ///
    /// For more information see [Apple's documentation for `shadow`](https://developer.apple.com/documentation/swiftui/view/shadow(color:radius:x:y:)).
    ///
    /// - Parameters:
    ///   - color: The shadow's color. Default is `Color(.sRGBLinear, white: 0, opacity: 0.33)`
    ///   - radius: A measure of how much to blur the shadow. Larger values
    ///     result in more blur.
    ///   - x: An amount to offset the shadow horizontally from the view. Default is `0`.
    ///   - y: An amount to offset the shadow vertically from the view. Default is `0`.
    func shadowIfLightColorScheme(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> some View {
        self.modifier(ShadowIfLightColorSchemeModifier(
            color: color,
            radius: radius,
            x: x,
            y: y
        ))
    }
}
