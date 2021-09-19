//
//  ToastView.swift
//
//  Created by Kelvin Kosbab on 7/30/21.
//

import SwiftUI

// MARK: - ToastView

/// Displayable content for a toast.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ToastView : View {
    
    @Binding private var content: ToastContent
    
    private let imageSize: CGFloat = Spacing.large
    
    init(_ content: Binding<ToastContent>) {
        self._content = content
    }
    
    var body: some View {
        HStack {
            if self.content.leadingImage != nil || self.content.trailingImage != nil {
                
                self.renderImageContent(self.content.leadingImage, isLeading: true)
                
                self.getTextContent(title: content.title, description: content.description)
                    .padding(.vertical, Spacing.tiny)
                    .padding(.horizontal, Spacing.base)
                
                self.renderImageContent(self.content.trailingImage, isLeading: false)
                
            } else {
                
                self.getTextContent(title: content.title, description: content.description)
                    .padding(.vertical, Spacing.small)
                    .padding(.horizontal, Spacing.xxl)
            }
        }
        .frame(minWidth: .zero,
               maxWidth: 330,
               minHeight: 54,
               maxHeight: .infinity)
        .fixedSize(horizontal: true,
                   vertical: true)
        .coreContainer(applyShadow: true,
                       backgroundStyle: .secondaryFill,
                       cornerStyle: .capsule)
    }
    
    private func getTextContent(title: String, description: String?) -> some View {
        VStack(spacing: Spacing.tiny) {
            Text(title)
                .footnoteBoldStyle(appFont: .systemBold)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
            if let description = description {
                Text(description)
                    .footnoteStyle(appFont: .systemRegular)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.gray)
            }
        }
    }
    
    @ViewBuilder
    private func renderImageContent(_ imageContent: (image: Image, tintColor: Color?)?, isLeading: Bool) -> some View {
        if let imageContent = imageContent {
            imageContent.image
                .resizable()
                .frame(width: self.imageSize, height: self.imageSize)
                .modifier(OptionalForegroundColorModifier(foregroundColor: imageContent.tintColor))
                .padding(.vertical, Spacing.tiny)
                .padding(isLeading ? .leading : .trailing, Spacing.base)
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(width: self.imageSize, height: self.imageSize)
                .padding(.vertical, Spacing.tiny)
                .padding(isLeading ? .leading : .trailing, Spacing.base)
        }
    }
}

// MARK: - Helpers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct OptionalForegroundColorModifier : ViewModifier {
    
    let foregroundColor: Color?
    
    func body(content: Content) -> some View {
        if let color = self.foregroundColor {
            content.foregroundColor(color)
        } else {
            content
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ToastView_Previews: PreviewProvider {
    
    static let image: Image = Image(systemName: "heart.circle.fill")
    
    static var previews: some View {
        VStack(spacing: Spacing.base) {
            ToastView(.constant(ToastContent(title: "One")))
            ToastView(.constant(ToastContent(title: "Two",
                                             leadingImage: (image: self.image, tintColor: .green))))
            ToastView(.constant(ToastContent(title: "Two",
                                             description: "Hello")))
            ToastView(.constant(ToastContent(title: "Two",
                                             description: "Hello",
                                             leadingImage: (image: self.image, tintColor: .blue),
                                             trailingImage: (image: self.image, tintColor: .blue))))
        }
    }
}

#endif
