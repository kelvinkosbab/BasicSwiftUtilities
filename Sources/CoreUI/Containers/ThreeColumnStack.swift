//
//  ThreeColumnStack.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - ThreeColumnStack

@available(iOS 13, *)
public struct ThreeColumnStack<Left, Center, Right>: View where Left: View, Center: View, Right: View {
    
    let left: () -> Left
    let center: () -> Center
    let right: () -> Right
    
    public init(@ViewBuilder left: @escaping () -> Left,
                @ViewBuilder center: @escaping () -> Center,
                @ViewBuilder right: @escaping () -> Right) {
        self.left = left
        self.center = center
        self.right = right
    }
    
    public var body: some View {
        HStack {
            HStack {
                left()
                Spacer()
            }
            center()
            HStack {
                Spacer()
                right()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13, *)
private struct Previews: PreviewProvider {
    
    static var previews: some View {
        ThreeColumnStack(left: {
            Text("Left")
        }, center: {
            Text("Center")
        }, right: {
            Text("Right")
        })
    }
}

#endif
