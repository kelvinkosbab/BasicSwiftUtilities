//
//  CoreRoundedView.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreRoundedView

@available(iOS 13, *)
public struct CoreRoundedView<Content : View> : View {
    
    private let content: Content
    private let cornerRadius: CGFloat?
    
    /// Constructor.
    ///
    /// - Parameter builder: Content of the button.
    /// - Parameter cornerRadius: Corner radius of the rounded view. If left as `default` or set
    /// to `nil` a `Capsule` backghround shape will be applied.
    public init(@ViewBuilder builder: () -> Content, cornerRadius: CGFloat? = nil) {
        self.content = builder()
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        HStack {
            HStack {
                self.content
            }
            .padding(Spacing.base)
            .background(Color(.tertiarySystemBackground))
            .modifier(RoundedViewModifier(cornerRadius: self.cornerRadius))
        }
        .background(Color(.secondarySystemFill))
        .modifier(RoundedViewModifier(cornerRadius: self.cornerRadius))
        .modifier(ViewShadowModifier())
    }
}

@available(iOS 13, *)
private struct ViewShadowModifier : ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    public func body(content: Content) -> some View {
        if self.colorScheme == .dark {
            content
        } else {
            content
                .shadow(color: .gray, radius: 3, x: 0, y: 1)
        }
    }
}

@available(iOS 13, *)
private struct RoundedViewModifier : ViewModifier {
    
    let cornerRadius: CGFloat?
    
    public func body(content: Content) -> some View {
        if let cornerRadius = self.cornerRadius {
            content
                .cornerRadius(cornerRadius)
        } else {
            content
                .background(Capsule())
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13, *)
private struct Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            CoreRoundedView {
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
