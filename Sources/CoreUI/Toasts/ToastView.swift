//
//  ToastView.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastView

/// Displayable content for a toast.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
struct ToastView : View {
    
    @Binding private var content: ToastContent
    
    private let imageSize: CGFloat = Spacing.large
    
    init(_ content: Binding<ToastContent>) {
        self._content = content
    }
    
    var body: some View {
        self.bodyWithoutBackground
            .toastBackground()
    }
    
    private var bodyWithoutBackground: some View {
        HStack {
            if self.content.leading != .none || self.content.trailing != .none {
                
                self.renderLeadingTrailingContent(
                    self.content.leading.body(),
                    isLeading: true
                )
                
                self.renderPrimaryContent(
                    title: self.content.title,
                    description: self.content.description
                )
                .padding(.vertical, Spacing.tiny)
                .padding(.horizontal, Spacing.base)
                
                self.renderLeadingTrailingContent(
                    self.content.trailing.body(),
                    isLeading: false
                )
                
            } else {
                
                self.renderPrimaryContent(
                    title: self.content.title,
                    description: self.content.description
                )
                .padding(.vertical, Spacing.small)
                .padding(.horizontal, Spacing.xxl)
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
    }
    
    private func renderPrimaryContent(
        title: ToastSimpleContent,
        description: ToastSimpleContent?
    ) -> some View {
        VStack(spacing: Spacing.tiny) {
            switch title {
            case .string(let titleString):
                if #available(iOS 16.0, *) {
                    Text(titleString)
                        .font(.system(.footnote, weight: .bold))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                } else {
                    Text(titleString)
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }
            default:
                Text("KAK TODO")
//                ToastDescriptionView(content: title, style: .primary)
            }
            if let description = description {
                Text("KAK TODO 2")
//                ToastDescriptionView(content: description, style: .secondary)
            }
        }
    }
    
    @ViewBuilder
    private func renderLeadingTrailingContent<Content>(
        _ content: Content,
        isLeading: Bool
    ) -> some View where Content: View {
        content
            .frame(width: self.imageSize, height: self.imageSize)
            .padding(.vertical, Spacing.tiny)
            .padding(isLeading ? .leading : .trailing, Spacing.base)
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
struct ToastView_Previews: PreviewProvider {
    
    static let image: Image = Image(systemName: "heart.circle.fill")
    
    static var previews: some View {
        VStack(spacing: Spacing.base) {
            
            ToastView(.constant(ToastContent(
                title: .string("Simple Toast with Title")
            )))
            .padding()
            
            ToastView(.constant(ToastContent(
                title: .string("Toast with Leading Image"),
                leading: .tintedImage(self.image, .green)
            )))
            .padding()
            
            ToastView(.constant(ToastContent(
                title: .string("Toast with 2 Images"),
                description: .string("Description"),
                leading: .tintedImage(self.image, .blue),
                trailing: .tintedImage(self.image, .green)
            )))
            .padding()
            
            ToastView(.constant(ToastContent(
                title: .string("Toast with Detail"),
                description: .string("Hello")
            )))
            .padding()
            
            ToastView(.constant(ToastContent(
                title: .string("Toast with Detail"),
                description: .leadingImage(
                    Image(systemName: "battery.75"),
                    description: "75%"
                )
            )))
            .padding()
            
            ToastView(.constant(ToastContent(
                title: .string("Toast with Detail"),
                description: .trailingImage(
                    Image(systemName: "battery.75"),
                    description: "75%"
                )
            )))
            .padding()
        }
    }
}

#endif
#endif
