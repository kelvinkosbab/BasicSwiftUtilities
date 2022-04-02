//
//  CircleButtons.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CircleTextButton

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
public struct CircleTextButton : View {
    
    private let title: String
    private let size: CGFloat
    private let tintColor: Color
    private let action: () -> Void
    
    public init(_ title: String,
                size: CGFloat = 100,
                tintColor: Color = AppColors.appTintColor,
                action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.tintColor = tintColor
        self.action = action
    }

    public var body: some View {
        Button(action: self.action) {
            Text(self.title)
                .bodyBoldStyle()
                .frame(width: self.size, height: self.size)
                .foregroundColor(.white)
                .background(self.tintColor)
                .clipShape(Circle())
        }
    }
}

// MARK: - CircleImageButton

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
public struct CircleImageButton : View {
    
    private let image: Image
    private let isIcon: Bool
    private let tintColor: Color
    private let action: () -> Void
    private let onPressDown: (() -> Void)?
    
    public init(_ systemName: String,
                size: CGFloat = 100,
                tintColor: Color = AppColors.appTintColor,
                action: @escaping () -> Void,
                onPressDown: (() -> Void)? = nil) {
        self.image = Image(systemName: systemName)
        self.isIcon = true
        self.tintColor = tintColor
        self.action = action
        self.onPressDown = onPressDown
    }
    
    public init(_ image: Image,
                tintColor: Color = AppColors.appTintColor,
                action: @escaping () -> Void,
                onPressDown: (() -> Void)? = nil) {
        self.image = image
        self.isIcon = false
        self.tintColor = tintColor
        self.action = action
        self.onPressDown = onPressDown
    }

    public var body: some View {
        Button(action: {}) {
            if self.isIcon {
                CircleImage(image: self.image)
                    .foregroundColor(self.tintColor)
                    .onTapGesture {
                        self.onPressDown?()
                        self.action()
                    }
            } else {
                CircleImage(image: self.image)
                    .onTapGesture {
                        self.onPressDown?()
                        self.action()
                    }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
struct Circle_Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            CircleTextButton("Hi") {
                // do nothing
            }
            CircleImageButton("plus.circle.fill") {
                // do nothing
            }
            CircleImageButton("minus.circle.fill") {
                // do nothing
            }
        }
    }
}

#endif
