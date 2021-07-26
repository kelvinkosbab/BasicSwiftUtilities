//
//  CoreRoundedView.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - RoundedViewStyle

public enum RoundedViewStyle {
    case capsule
    case corenerRadius(CGFloat)
}

// MARK: - CoreRoundedView

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CoreRoundedView<Content : View> : View {
    
    private let content: Content
    private let style: RoundedViewStyle
    
    /// Constructor.
    ///
    /// - Parameter builder: Content of the button.
    /// - Parameter cornerRadius: Corner radius of the rounded view. If left as `default` or set
    /// to `nil` a `Capsule` backghround shape will be applied.
    public init(_ style: RoundedViewStyle, @ViewBuilder builder: () -> Content) {
        self.content = builder()
        self.style = style
    }
    
    public var body: some View {
        HStack {
            HStack {
                self.content
            }
            .padding(Spacing.base)
        }
        .background(Color(.secondarySystemFill))
        .modifier(RoundedViewModifier(style: self.style))
        .coreShadow()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct RoundedViewModifier : ViewModifier {
    
    let style: RoundedViewStyle
    
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

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            CoreRoundedView(.corenerRadius(20)) {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Left Top")
                    Text("Left Bottom")
                }
                Spacer()
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Trailing")
                }
            }
            CoreRoundedView(.capsule) {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Left Top")
                    Text("Left Bottom")
                }
                Spacer()
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Trailing")
                }
            }
        }
    }
}

#endif
