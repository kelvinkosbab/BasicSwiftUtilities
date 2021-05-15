//
//  CircleButtons.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CircleTextButton

@available(iOS 13, *)
public struct CircleTextButton : View {
    
    @Binding public var title: String
    let size: CGFloat
    let action: () -> Void
    
    public init(_ title: Binding<String>,
                size: CGFloat = 100,
                action: @escaping () -> Void) {
        self._title = title
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: self.action) {
            Text(self.title)
                .bodyBoldStyle()
                .frame(width: self.size, height: self.size)
                .foregroundColor(.white)
                .background(Color.tallyBokBlue)
                .clipShape(Circle())
        }
    }
}

// MARK: - CircleImageButton

@available(iOS 13, *)
public struct CircleImageButton : View {
    
    let image: Image
    let isIcon: Bool
    let action: () -> Void
    let onPressDown: (() -> Void)?
    
    public init(_ systemName: String,
                size: CGFloat = 100,
                action: @escaping () -> Void,
                onPressDown: (() -> Void)? = nil) {
        self.image = Image(systemName: systemName)
        self.isIcon = true
        self.action = action
        self.onPressDown = onPressDown
    }
    
    public init(_ image: Image,
                action: @escaping () -> Void,
                onPressDown: (() -> Void)? = nil) {
        self.image = image
        self.isIcon = false
        self.action = action
        self.onPressDown = onPressDown
    }

    public var body: some View {
        Button(action: {}) {
            if self.isIcon {
                CircleImage(image: self.image)
                    .foregroundColor(.tallyBokBlue)
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

@available(iOS 13, *)
private struct Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            CircleTextButton(.constant("Hi")) {
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
