//
//  SimpleToastImage.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - SimpleToastImage

// MARK: - Preview

struct SimpleToastImage_Previews: PreviewProvider {
    
    static let fontSize: CGFloat = 70
    
    static var previews: some View {
        VStack(spacing: Spacing.base) {
            Image(systemName: "theatermasks")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
                .font(.system(size: fontSize))
            
            Image(systemName: "shareplay")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.primary, .secondary)
                .font(.system(size: fontSize))
            
            Image(systemName: "person.3.sequence.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.blue, .green, .red)
                .font(.system(size: fontSize))
            
            Image(systemName: "person.3.sequence.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    .linearGradient(colors: [.red, .clear], startPoint: .top, endPoint: .bottomTrailing),
                    .linearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottomTrailing),
                    .linearGradient(colors: [.blue, .clear], startPoint: .top, endPoint: .bottomTrailing)
                )
                .font(.system(size: fontSize))
        }
    }
}

#endif
