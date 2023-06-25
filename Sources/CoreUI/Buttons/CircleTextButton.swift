//
//  CircleTextButton.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

#if !os(macOS)

import SwiftUI

// MARK: - CircleTextButton

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public struct CircleTextButton : View {
    
    private let title: String
    private let font: Font?
    private let foregroundColor: Color
    private let backgroundColor: Color
    private let size: CGFloat
    private let action: () -> Void
    
    public init(
        _ title: String,
        font: Font? = nil,
        foregroundColor: Color = .white,
        backgroundColor: Color,
        size: CGFloat,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.font = font
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: self.action) {
            Text(self.title)
                .font(self.font)
                .frame(width: self.size, height: self.size)
                .foregroundColor(self.foregroundColor)
                .background(self.backgroundColor)
                .clipShape(Circle())
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
struct CircleTextButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            CircleTextButton(
                "Hello",
                backgroundColor: .blue,
                size: 100
            ) {
                // do nothing
            }
            CircleTextButton(
                "Hello",
                font: .system(
                    size: 18,
                    weight: .heavy,
                    design: .default
                ),
                foregroundColor: .black,
                backgroundColor: .yellow,
                size: 100
            ) {
                // do nothing
            }
        }
    }
}

#endif
#endif
