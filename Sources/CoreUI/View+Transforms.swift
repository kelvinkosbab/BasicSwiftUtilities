//
//  View+Transforms .swift
//
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// ```
    /// var body: some view {
    ///     myView
    ///         .if(X) { $0.padding(8) }
    ///         .if(!X) { $0.background(Color.blue) }
    /// }
    /// ```
    ///
    /// Source: https://fivestars.blog/swiftui/conditional-modifiers.html
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// ```
    /// var body: some view {
    ///     myView
    ///         .if(X) { $0.padding(8) } else: { $0.background(Color.blue) }
    /// }
    /// ```
    ///
    /// Source: https://fivestars.blog/swiftui/conditional-modifiers.html
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(_ condition: Bool, if ifTransform: (Self) -> TrueContent, else elseTransform: (Self) -> FalseContent ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
}
