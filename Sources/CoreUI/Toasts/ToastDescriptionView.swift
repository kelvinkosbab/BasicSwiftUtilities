//
//  ToastDescriptionView.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - ToastDescriptionView

/// Displays a styled text view for the description of a toast view.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
public struct ToastDescriptionView : View {
    
    /// Determines what kind of content to render in the description under the title of the toast.
    public enum ContentType {
        
        /// Description is string.
        case string(String)
        
        /// Description is an image.
        case image(_ image: Image)
        
        /// Description is an image followed by a string.
        case leadingImage(
            _ image: Image,
            description: String
        )
        
        /// Description is a string followed by an image.
        case trailingImage(
            _ image: Image,
            description: String
        )
    }
    
    let content: ContentType
    
    public var body: some View {
        HStack {
            switch self.content {
            case .string(let description):
                self.render(text: description)
                
            case .image(let image):
                self.render(image: image)
                
            case .leadingImage(
                let image,
                description: let description
            ):
                HStack {
                    self.render(image: image)
                    self.render(text: description)
                }
                
            case .trailingImage(
                let image,
                description: let description
            ):
                HStack {
                    self.render(text: description)
                    self.render(image: image)
                }
            }
        }
    }
    
    private func render(text: String) -> some View {
        Text(text)
            .font(.footnote)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
    }
    
    private func render(image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
            .frame(
                width: Spacing.large,
                height: Spacing.base
            )
            .foregroundStyle(.secondary)
    }
}

// MARK: - Preview

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
struct ToastDescriptionView_Previews: PreviewProvider {
    
    static let mockImage: Image = Image(systemName: "battery.75")
    
    static let mockString: String = "Simple string"
    
    static var previews: some View {
        VStack(spacing: Spacing.base) {
            
            ToastDescriptionView(
                content: .string(self.mockString)
            )
            .padding()
            
            ToastDescriptionView(
                content: .image(self.mockImage)
            )
            .padding()
            
            ToastDescriptionView(
                content: .leadingImage(
                    self.mockImage,
                    description: self.mockString
                )
            )
            .padding()
            
            ToastDescriptionView(
                content: .trailingImage(
                    self.mockImage,
                    description: self.mockString
                )
            )
            .padding()
        }
    }
}

#endif
