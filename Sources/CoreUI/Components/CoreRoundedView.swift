//
//  CoreRoundedView.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - RoundedViewCornerStyle

public enum RoundedViewCornerStyle {
    case capsule
    case corenerRadius(CGFloat)
}

// MARK: - RoundedViewBackgroundStyle

public enum RoundedViewBackgroundStyle {
    case secondarySystemFill
    case blur
}

// MARK: - CoreRoundedView

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CoreRoundedView<Content : View> : View {
    
    // MARK: - Properties and Init
    
    private let backgroundStyle: RoundedViewBackgroundStyle
    private let content: Content
    private let cornerStyle: RoundedViewCornerStyle
    
    /// Constructor.
    ///
    /// - Parameter cornerStyle: Style of the corners of the view..
    /// - Parameter backgroundStyle: Style of the background container. Default is `secondarySystemFill`.``
    /// - Parameter builder: Content of the button.
    /// to `nil` a `Capsule` backghround shape will be applied.
    public init(_ cornerStyle: RoundedViewCornerStyle,
                backgroundStyle: RoundedViewBackgroundStyle = .secondarySystemFill,
                @ViewBuilder builder: () -> Content) {
        self.backgroundStyle = backgroundStyle
        self.content = builder()
        self.cornerStyle = cornerStyle
    }
    
    public var body: some View {
        HStack {
            HStack {
                self.content
            }
            .background(self.backgroundStyle == .secondarySystemFill ? Color(.secondarySystemFill) : .clear)
        }
        .modifier(RoundedViewBackgroundModifier(style: self.backgroundStyle))
        .modifier(RoundedViewModifier(style: self.cornerStyle))
        .coreShadow()
    }
}

// MARK: - RoundedViewModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct RoundedViewModifier : ViewModifier {
    
    let style: RoundedViewCornerStyle
    
    public func body(content: Content) -> some View {
        switch self.style {
        case .capsule:
            content
                .clipShape(Capsule())
        case .corenerRadius(let corenerRadius):
            content
                .clipShape(RoundedRectangle(cornerRadius: corenerRadius))
        }
    }
}

// MARK: - RoundedViewBackgroundModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct RoundedViewBackgroundModifier : ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    let style: RoundedViewBackgroundStyle
    
    public func body(content: Content) -> some View {
        switch self.style {
        case .secondarySystemFill:
            content
                .background(self.colorScheme == .dark ? Color.black : Color.white)
        case .blur:
            content
                .background(Blur())
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CoreRoundedView_Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            CoreRoundedView(.corenerRadius(20)) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Left Top")
                        Text("Left Bottom")
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Trailing")
                    }
                }
                .padding()
            }
            CoreRoundedView(.capsule) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Left Top")
                        Text("Left Bottom")
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Trailing")
                    }
                }
                .padding()
            }
        }
    }
}

#endif
