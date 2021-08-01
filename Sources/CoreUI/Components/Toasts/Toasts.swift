//
//  Toasts.swift
//
//  Created by Kelvin Kosbab on 7/30/21.
//

import SwiftUI

// MARK: - ToastContent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ToastContent {
    
    let title: String
    let description: String?
    let image: Image?
    let tintColor: Color?
    
    public init(title: String,
                description: String? = nil,
                image: Image? = nil,
                tintColor: Color? = nil) {
        self.title = title
        self.description = description
        self.image = image
        self.tintColor = tintColor
    }
}

// MARK: - ToastView

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ToastView : View {
    
    @Binding private var content: ToastContent
    
    public init(_ content: Binding<ToastContent>) {
        self._content = content
    }
    
    public var body: some View {
        CoreRoundedView(.capsule) {
            HStack {
                if let image = self.content.image, let tintColor = self.content.tintColor {
                    
                    image
                        .resizable()
                        .frame(maxHeight: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(tintColor)
                        .padding()
                    
                    Spacer()
                    
                    self.textContent
                        .padding()
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(maxHeight: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .padding()
                    
                } else {
                    
                    self.textContent
                        .padding()
                }
            }
            .frame(width: 300)
            .frame(maxHeight: 60)
        }
    }
    
    private var textContent: some View {
        VStack(spacing: Spacing.tiny) {
            Text(self.content.title)
                .bodyBoldStyle()
                .foregroundColor(Color.primary)
                .lineLimit(1)
            if let description = self.content.description {
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
