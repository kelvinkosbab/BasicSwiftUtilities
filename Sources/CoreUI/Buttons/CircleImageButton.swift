//
//  CircleImageButton.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import SwiftUI

// MARK: - CircleImageButton

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public struct CircleImageButton : View {
    
    private let image: Image
    private let size: CGFloat
    private let isIcon: Bool
    private let tintColor: Color
    private let action: () -> Void
    
    public init(
        _ systemName: String,
        size: CGFloat,
        tintColor: Color,
        action: @escaping () -> Void
    ) {
        self.image = Image(systemName: systemName)
        self.size = size
        self.isIcon = true
        self.tintColor = tintColor
        self.action = action
    }
    
    public init(
        _ image: Image,
        size: CGFloat,
        tintColor: Color,
        action: @escaping () -> Void,
        onPressDown: (() -> Void)? = nil
    ) {
        self.image = image
        self.size = size
        self.isIcon = false
        self.tintColor = tintColor
        self.action = action
    }

    public var body: some View {
        Button(action: {}) {
            if self.isIcon {
                CircleImage(image: self.image)
                    .foregroundColor(self.tintColor)
                    .onTapGesture {
                        self.action()
                    }
                    .frame(width: self.size, height: self.size)
            } else {
                CircleImage(image: self.image)
                    .onTapGesture {
                        self.action()
                    }
                    .frame(width: self.size, height: self.size)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
struct CircleImageButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            CircleImageButton("plus.circle.fill", size: 100, tintColor: .blue) {
                // do nothing
            }
            CircleImageButton("minus.circle.fill", size: 100, tintColor: .blue) {
                // do nothing
            }
        }
    }
}

#endif
#endif
