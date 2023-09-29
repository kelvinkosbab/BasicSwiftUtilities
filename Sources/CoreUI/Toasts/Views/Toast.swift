//
//  Toast.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - Toast

/// Displayable content for a toast.
struct Toast<Content, Leading, Trailing> : View where Content: View, Leading: View, Trailing: View {
    
    let content: () -> Content
    let leading: (() -> Leading)?
    let trailing: (() -> Trailing)?
    
    /// TODO documentation
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.content = content
        self.leading = leading
        self.trailing = trailing
    }
    
    var body: some View {
        HStack {
            HStack {
                if let leading {
                    leading()
                        .padding(.vertical, Spacing.tiny)
                        .padding(.leading, Spacing.base)
                } else {
                    self.renderClearRectangle
                }
                Spacer()
            }
            
            self.content()
                .padding(.vertical, Spacing.tiny)
                .padding(.horizontal, Spacing.small)
            
            HStack {
                Spacer()
                if let trailing {
                    trailing()
                        .padding(.vertical, Spacing.tiny)
                        .padding(.trailing, Spacing.base)
                } else {
                    self.renderClearRectangle
                }
            }
        }
        .frame(
            minWidth: .zero,
            maxWidth: 330,
            minHeight: 54,
            maxHeight: .infinity
        )
        .fixedSize(
            horizontal: true,
            vertical: true
        )
        .modifier(ToastBackgroundModifier())
    }
    
    private var renderClearRectangle: some View {
        Rectangle()
            .fill(.clear)
            .frame(width: Spacing.large, height: Spacing.large)
    }
}

// MARK: - Preview

struct Toast_Previews: PreviewProvider {
    
    static var mockContent: some View {
        Text("Hello there")
            .font(.footnote)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .foregroundColor(.primary)
    }
    
    static var previews: some View {
        VStack(spacing: Spacing.base) {
            
            Toast {
                self.mockContent
            } leading: {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
            } trailing: {
                Image(systemName: "person.3.sequence.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.blue, .green, .red)
            }
            
            Toast {
                VStack(spacing: Spacing.tiny) {
                    self.mockContent
                    self.mockContent
                }
            } leading: {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
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
    }
}

#endif
