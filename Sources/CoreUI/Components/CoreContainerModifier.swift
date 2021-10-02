//
//  CoreContainerModifier.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - RoundedViewCornerStyle

public enum RoundedViewCornerStyle {
    case none
    case capsule
    case corenerRadius(CGFloat)
}

// MARK: - RoundedViewBackgroundStyle

public enum RoundedViewBackgroundStyle {
    case blur(UIBlurEffect.Style)
    case secondaryFill
    case tertiaryFill
    case quaternaryFill
}

// MARK: - ShadowStyle

public enum ShadowStyle {
    case none
    case lightColorScheme
    case shadow
}

// MARK: - CoreRoundedView

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CoreContainerModifier : ViewModifier {
    
    // MARK: - Properties and Init
    
    @Environment(\.colorScheme) var colorScheme
    
    private let shadowStyle: ShadowStyle
    private let backgroundStyle: RoundedViewBackgroundStyle
    private let cornerStyle: RoundedViewCornerStyle
    
    /// Constructor.
    ///
    /// - Parameter shadowStyle: Shadow style to apply to the container.
    /// - Parameter cornerStyle: Style of the corners of the view..
    /// - Parameter backgroundStyle: Style of the background container. Default is `none`.``
    init(shadowStyle: ShadowStyle,
         backgroundStyle: RoundedViewBackgroundStyle,
         cornerStyle: RoundedViewCornerStyle) {
        self.shadowStyle = shadowStyle
        self.backgroundStyle = backgroundStyle
        self.cornerStyle = cornerStyle
    }
    
    func body(content: Content) -> some View {
        HStack {
            HStack {
                content
            }
            .modifier(InnerBackgroundModifier(style: self.backgroundStyle))
        }
        .modifier(OuterBackgroundModifier(style: self.backgroundStyle))
        .modifier(RoundedViewModifier(style: self.cornerStyle))
        .modifier(ShadowModifier(shadowStyle: self.shadowStyle))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// View container utility for shadows, corner radius and rounded styles as well as background color styles.
    ///
    /// - Parameter shadowStyle: Shadow style to apply to the container.
    /// - Parameter cornerStyle: Style of the corners of the view..
    /// - Parameter backgroundStyle: Style of the background container. Default is `none`.``
    func coreContainer(shadowStyle: ShadowStyle = .lightColorScheme,
                       backgroundStyle: RoundedViewBackgroundStyle,
                       cornerStyle: RoundedViewCornerStyle = .none) -> some View {
        self.modifier(CoreContainerModifier(shadowStyle: shadowStyle,
                                            backgroundStyle:  backgroundStyle,
                                            cornerStyle: cornerStyle))
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
        case .none:
            content
        }
    }
}

// MARK: - InnerBackgroundModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct InnerBackgroundModifier : ViewModifier {
    
    let style: RoundedViewBackgroundStyle
    
    public func body(content: Content) -> some View {
        switch self.style {
        case .blur:
            content
        case .secondaryFill:
            content
                .background(Color(.secondarySystemFill))
        case .tertiaryFill:
            content
                .background(Color(.tertiarySystemFill))
        case .quaternaryFill:
            content
                .background(Color(.quaternarySystemFill))
        }
    }
}

// MARK: - OuterBackgroundModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct OuterBackgroundModifier : ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    let style: RoundedViewBackgroundStyle
    
    public func body(content: Content) -> some View {
        switch self.style {
        case .blur(let style):
            content
                .blurred(style)
        case .secondaryFill, .tertiaryFill, .quaternaryFill:
            content
                .background(self.colorScheme == .dark ? Color.black : Color.white)
        }
    }
}

// MARK: - ShadowModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct ShadowModifier : ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    let shadowStyle: ShadowStyle
    
    public func body(content: Content) -> some View {
        switch self.shadowStyle {
        case .none:
            content
        case .lightColorScheme:
            if self.colorScheme == .light {
                content
                    .coreShadow()
            } else {
                content
            }
        case .shadow:
            content
                .coreShadow()
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CoreRoundedView_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollView {
            VStack(spacing: 10) {
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
                .coreContainer(backgroundStyle: .secondaryFill, cornerStyle: .corenerRadius(25))
                
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
                .coreContainer(backgroundStyle: .secondaryFill, cornerStyle: .capsule)
                
                Text("Content").padding().coreContainer(backgroundStyle: .blur(.prominent), cornerStyle: .capsule)
                Text("Content").padding().coreContainer(backgroundStyle: .secondaryFill, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(backgroundStyle: .tertiaryFill, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(backgroundStyle: .quaternaryFill, cornerStyle: .capsule)
                
                Text("Content").padding().coreContainer(shadowStyle: .shadow, backgroundStyle: .quaternaryFill, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(shadowStyle: .none, backgroundStyle: .quaternaryFill, cornerStyle: .capsule)
            }
        }
    }
}

#endif
