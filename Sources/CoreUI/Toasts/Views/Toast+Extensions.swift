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
    
    /// TODO documentation
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) where Leading == EmptyView {
        self.content = content
        self.leading = nil
        self.trailing = trailing
    }
    
    /// TODO documentation
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder leading: @escaping () -> Leading
    ) where Trailing == EmptyView {
        self.content = content
        self.leading = leading
        self.trailing = nil
    }
    
    /// TODO documentation
    init(
        @ViewBuilder content: @escaping () -> Content
    ) where Leading == EmptyView, Trailing == EmptyView {
        self.content = content
        self.leading = nil
        self.trailing = nil
    }
    
    // MARK: - Simple Type Extensions
    
    /// TODO documentation
    ///
    /// Renders a view with a `footnote` title
    init(
        title: String
    ) where Content == SimpleToastText, Leading == EmptyView, Trailing == EmptyView {
        self.content = {
            SimpleToastText(
                text: title,
                foregroundStyle: .primary
            )
        }
        self.leading = nil
        self.trailing = nil
    }
    
    /// TODO documentation
    ///
    /// Renders a view with a `footnote` title and description below it
    init(
        title: String,
        description: String
    ) where Content == VStack<TupleView<(SimpleToastText, SimpleToastText)>>, Leading == EmptyView, Trailing == EmptyView {
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
    
    // MARK: - Extensions for Leading & Trailing Images
    
    /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-get-custom-colors-and-transparency-with-sf-symbols
    /// 
    /// Options
    /// - `.foregroundColor(.blue)`
    /// - `.symbolRenderingMode(.hierarchical)`
    /// - `.symbolRenderingMode(.palette)`
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
            
            Toast {
                self.mockContent
            }
            
            Toast {
                HStack {
                    Circle()
                        .foregroundColor(.cyan)
                        .padding()
                    Rectangle()
                        .foregroundColor(.green)
                        .padding()
                }
            }
            
            Toast {
                self.mockContent
            } leading: {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
            }
            
            Toast {
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
        }
        .previewDisplayName("Generic Extensions")
        
        VStack(spacing: Spacing.base) {
            
            Toast(title: "Simple title only")
            
            Toast(
                title: "Simple title",
                description: "And a description"
            )
        }
        .previewDisplayName("Simple Type Extensions")
    }
}

#endif
