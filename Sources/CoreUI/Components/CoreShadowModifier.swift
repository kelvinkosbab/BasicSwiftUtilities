//
//  CoreShadowModifier.swift
//
//  Created by Kelvin Kosbab on 7/25/21.
//

import SwiftUI

// MARK: - CoreShadowModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CoreShadowModifier : ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    public func body(content: Content) -> some View {
        if self.colorScheme == .dark {
            content
        } else {
            content
                .shadow(color: .gray, radius: 3, x: 0, y: 1)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    func coreShadow() -> some View {
        self.modifier(CoreShadowModifier())
    }
}
