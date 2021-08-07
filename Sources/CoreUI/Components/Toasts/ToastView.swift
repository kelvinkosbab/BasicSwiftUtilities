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
                    .frame(maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(tintColor)
                    .padding()
                
                Spacer()
                
                self.getTextContent(title: content.title, description: content.description)
                    .padding()
                
                Spacer()
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .padding()
                
            } else {
                
                self.getTextContent(title: content.title, description: content.description)
                    .padding()
            }
        }
        .coreContainer(applyShadow: true,
                       backgroundStyle: .secondaryFill,
                       cornerStyle: .capsule)
        .frame(width: 300)
        .frame(maxHeight: 60)
    }
    
    private func getTextContent(title: String, description: String?) -> some View {
        VStack(spacing: Spacing.tiny) {
            Text(title)
                .bodyBoldStyle()
                .foregroundColor(Color.primary)
                .lineLimit(1)
            if let description = description {
                Text(description)
                    .footnoteBoldStyle()
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
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
