//
//  CoreToastContent.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - CoreToastContent

/// Displayable content for a toast.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
struct CoreToastContent<Content: View, Leading: View, Trailing: View> : View {
    
    let content: () -> Content
    let leading: (() -> Leading)?
    let trailing: (() -> Trailing)?
    
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.content = content
        self.leading = leading
        self.trailing = trailing
    }
    
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) where Leading == EmptyView {
        self.content = content
        self.leading = nil
        self.trailing = trailing
    }
    
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder leading: @escaping () -> Leading
    ) where Trailing == EmptyView {
        self.content = content
        self.leading = leading
        self.trailing = nil
    }
    
    init(@ViewBuilder content: @escaping () -> Content) where Leading == EmptyView, Trailing == EmptyView {
        self.content = content
        self.leading = nil
        self.trailing = nil
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
        .toastBackground()
    }
    
    private var renderClearRectangle: some View {
        Rectangle()
            .fill(.clear)
            .frame(width: Spacing.large, height: Spacing.large)
    }
}

// MARK: - Preview

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
struct CoreToastContent_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing: Spacing.base) {
            
            CoreToastContent {
                Text("Hello there")
                    .font(.footnote)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .padding()
            
            CoreToastContent {
                Text("Hello there")
                    .font(.footnote)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            } leading: {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
            } trailing: {
                Image(systemName: "person.3.sequence.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.blue, .green, .red)
            }
            .padding()
            
            CoreToastContent {
                Text("Hello there")
                    .font(.footnote)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            } leading: {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding()
            
            CoreToastContent {
                Text("Hello there")
                    .font(.footnote)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            } trailing: {
                Image(systemName: "person.3.sequence.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        .linearGradient(colors: [.red, .clear], startPoint: .top, endPoint: .bottomTrailing),
                        .linearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottomTrailing),
                        .linearGradient(colors: [.blue, .clear], startPoint: .top, endPoint: .bottomTrailing)
                    )
            }
            .padding()
        }
    }
}

#endif
