//
//  File.swift
//  
//
//  Created by Kelvin Kosbab on 11/18/23.
//

import SwiftUI
 
// MARK: - VerticalScrollOnDynamicTypeSize

private struct VerticalScrollOnDynamicTypeSize: ViewModifier {

    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    let minSizeToScroll: DynamicTypeSize

    func body(content: Content) -> some View {
        if self.dynamicTypeSize >= self.minSizeToScroll {
            ScrollView(.vertical) {
                content
            }
        } else {
            content
        }
    }
}

// MARK: - View Extensions

public extension View {

    /// When a dynamic type size is equal to or greater than the specified dynamic type size wraps a vertical `ScrollView`.
    ///
    /// This is useful for supporting all accessiblity dynamic types for a view in an app. To determine what dynamic size to set in
    /// this method utilize Xcode Instruments Accessibility Inspector for the simulator as well as the Xcode previews dynamic
    /// type size control.
    ///
    /// - Note: If your view has horizontally oriented items it is advices to also dynamically switch between horizontal and
    /// vertical layouts. [For example](https://tiny.amazon.com/vkfiicxv/hackquicswifhowt).
    ///
    /// - Note: Utilizing `Spacer` s in the scroll view will contract to each view's set padding values.
    ///
    /// Usage:
    /// ```swift
    /// VStack {
    ///     Header()
    ///     Spacer()
    ///     BodyContent()
    ///     Spacer()
    ///     Footer()
    /// }
    /// .verticalScroll(greaterThanEqualTo: .accessibility2)
    /// ```
    ///
    /// - Parameter dynamicTypeSize: Size to apply the vertical `ScrollView`.
    ///
    ///
    /// - Warning: If your view already contains a vertically scrolling `List` or `ScrollView` you should not
    /// use this component.
    func verticalScroll(greaterThanEqualTo dynamicTypeSize: DynamicTypeSize) -> some View {
        modifier(VerticalScrollOnDynamicTypeSize(minSizeToScroll: dynamicTypeSize))
    }
}

// MARK: - Previews

#Preview("ScrollOnDynamicTypeSize") {
    VStack {
        Text("Hello there")
        Spacer()
        Text("Body content")
        Spacer()
        Text("Footer")
    }
    .verticalScroll(greaterThanEqualTo: .accessibility2)
}
