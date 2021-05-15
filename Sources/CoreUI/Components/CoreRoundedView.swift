//
//  CoreRoundedView.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreRoundedView

@available(iOS 13, *)
public struct CoreRoundedView<Content : View> : View {
    
    private let content: Content
    private let cornerRadius: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    public init(@ViewBuilder builder: () -> Content, cornerRadius: CGFloat = 33) {
        self.content = builder()
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        if self.colorScheme == .dark {
            HStack {
                HStack {
                    self.content
                }
                .padding(Spacing.base)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(self.cornerRadius)
            }
            .background(Color(.secondarySystemFill))
            .cornerRadius(self.cornerRadius)
        } else {
            HStack {
                HStack {
                    self.content
                }
                .padding(Spacing.base)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(self.cornerRadius)
            }
            .background(Color(.secondarySystemFill))
            .cornerRadius(self.cornerRadius)
            .shadow(color: .gray, radius: 3, x: 0, y: 1)
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13, *)
private struct Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            CoreRoundedView {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Left Top")
                    Text("Left Bottom")
                }
                Spacer()
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Trailing")
                }
            }
        }
    }
}

#endif
