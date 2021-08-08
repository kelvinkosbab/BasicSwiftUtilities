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
    
    init(_ content: Binding<ToastContent>) {
        self._content = content
    }
    
    var body: some View {
        HStack {
            if let image = content.image, let tintColor = content.tintColor {
                
                image
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(tintColor)
                    .padding(.vertical, Spacing.base)
                    .padding(.leading, Spacing.small)
                
                self.getTextContent(title: content.title, description: content.description)
                    .padding(.vertical, Spacing.tiny)
                    .padding(.horizontal, Spacing.small)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 30, height: 30)
                    .padding(.vertical, Spacing.base)
                    .padding(.trailing, Spacing.small)
                
            } else {
                
                self.getTextContent(title: content.title, description: content.description)
                    .padding(.vertical, Spacing.base)
                    .padding(.horizontal, Spacing.xxl)
            }
        }
        .frame(minWidth: .zero,
               maxWidth: 330,
               minHeight: .zero,
               maxHeight: 80)
        .fixedSize(horizontal: true,
                   vertical: true)
        .coreContainer(applyShadow: true,
                       backgroundStyle: .secondaryFill,
                       cornerStyle: .capsule)
    }
    
    private func getTextContent(title: String, description: String?) -> some View {
        VStack(spacing: Spacing.tiny) {
            Text(title)
                .footnoteBoldStyle()
                .lineLimit(1)
                .foregroundColor(Color.primary)
            if let description = description {
                Text(description)
                    .footnoteStyle()
                    .lineLimit(1)
                    .foregroundColor(Color.gray)
            }
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
                                             image: self.image,
                                             tintColor: .green)))
            ToastView(.constant(ToastContent(title: "Two",
                                             description: "Hello")))
            ToastView(.constant(ToastContent(title: "Two",
                                             description: "Hello",
                                             image: self.image,
                                             tintColor: .blue)))
        }
    }
}

#endif
