//
//  Toast+Extensions.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - Toast

extension Toast {

    // MARK: - Generic Extensions

    /// Creates a toast view.
    ///
    /// - Parameter shape: Defines the shape of the toast.
    /// - Parameter content: Defines content that is rendered in the center of the toast.
    /// - Parameter trailing: Defines content that is rendered on the trailing side of the toast.
    init(
        shape: ToastOptions.Shape,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) where Leading == EmptyView {
        self.shape = shape
        self.content = content
        self.leading = nil
        self.trailing = trailing
    }

    /// Creates a toast view.
    ///
    /// - Parameter shape: Defines the shape of the toast.
    /// - Parameter content: Defines content that is rendered in the center of the toast.
    /// - Parameter leading: Defines content that is rendered on the leading side of the toast.
    init(
        shape: ToastOptions.Shape,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder leading: @escaping () -> Leading
    ) where Trailing == EmptyView {
        self.shape = shape
        self.content = content
        self.leading = leading
        self.trailing = nil
    }

    /// Creates a toast view.
    ///
    /// - Parameter shape: Defines the shape of the toast.
    /// - Parameter content: Defines content that is rendered in the center of the toast.
    init(
        shape: ToastOptions.Shape,
        @ViewBuilder content: @escaping () -> Content
    ) where Leading == EmptyView, Trailing == EmptyView {
        self.shape = shape
        self.content = content
        self.leading = nil
        self.trailing = nil
    }

    // MARK: - Simple Type Extensions

    /// Creates a toast view with a simple title.
    ///
    /// - Parameter shape: Defines the shape of the toast.
    /// - Parameter title: Primary text of the toast.
    init(
        shape: ToastOptions.Shape,
        title: String
    ) where Content == SimpleToastText, Leading == EmptyView, Trailing == EmptyView {
        self.shape = shape
        self.content = {
            SimpleToastText(
                text: title,
                foregroundStyle: .primary
            )
        }
        self.leading = nil
        self.trailing = nil
    }

    /// Creates a toast view with a simple title.
    ///
    /// - Parameter shape: Defines the shape of the toast.
    /// - Parameter title: Primary text of the toast.
    /// - Parameter description: Secondary text of the toast.
    init(
        shape: ToastOptions.Shape,
        title: String,
        description: String
    ) where Content == VStack<TupleView<(SimpleToastText, SimpleToastText)>>, Leading == EmptyView, Trailing == EmptyView {
        self.shape = shape
        self.content = {
            VStack(spacing: Spacing.small) {
                SimpleToastText(
                    text: title,
                    foregroundStyle: .primary
                )
                SimpleToastText(
                    text: description,
                    foregroundStyle: .secondary
                )
            }
        }
        self.leading = nil
        self.trailing = nil
    }
}

// MARK: - Preview

struct ToastExtensions_Previews: PreviewProvider {

    static var mockContent: some View {
        Text("Hello there")
            .font(.body)
            .foregroundColor(.primary)
    }

    static var previews: some View {
        VStack(spacing: Spacing.base) {

            Toast(shape: .capsule) {
                self.mockContent
            }

            Toast(shape: .capsule) {
                HStack {
                    Circle()
                        .foregroundColor(.cyan)
                        .padding()
                    Rectangle()
                        .foregroundColor(.green)
                        .padding()
                }
            }

            Toast(shape: .capsule) {
                self.mockContent
            } leading: {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
            }

            Toast(shape: .capsule) {
                self.mockContent
            } trailing: {
                Image(systemName: "person.3.sequence.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        .linearGradient(colors: [.red, .clear], startPoint: .top, endPoint: .bottomTrailing),
                        .linearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottomTrailing),
                        .linearGradient(colors: [.blue, .clear], startPoint: .top, endPoint: .bottomTrailing)
                    )
            }

            Toast(shape: .capsule, title: "Simple title only")

            Toast(
                shape: .capsule,
                title: "Simple title",
                description: "And a description"
            )
        }
        .previewDisplayName("Capsule Extensions")

        VStack(spacing: Spacing.base) {

            Toast(shape: .roundedRectangle) {
                self.mockContent
            }

            Toast(shape: .roundedRectangle) {
                HStack {
                    Circle()
                        .foregroundColor(.cyan)
                        .padding()
                    Rectangle()
                        .foregroundColor(.green)
                        .padding()
                }
            }

            Toast(shape: .roundedRectangle) {
                self.mockContent
            } leading: {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
            }

            Toast(shape: .roundedRectangle) {
                self.mockContent
            } trailing: {
                Image(systemName: "person.3.sequence.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        .linearGradient(colors: [.red, .clear], startPoint: .top, endPoint: .bottomTrailing),
                        .linearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottomTrailing),
                        .linearGradient(colors: [.blue, .clear], startPoint: .top, endPoint: .bottomTrailing)
                    )
            }

            Toast(shape: .roundedRectangle, title: "Simple title only")

            Toast(
                shape: .roundedRectangle,
                title: "Simple title",
                description: "And a description"
            )
        }
        .previewDisplayName("RoundedRectangle Extensions")
    }
}

#endif
