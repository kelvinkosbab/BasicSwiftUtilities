//
//  CircleImage.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CircleImage

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public struct CircleImage : View {
    
    let image: Image
    
    public init(systemName: String) {
        self.image = Image(systemName: systemName)
    }
    
    public init(image: Image) {
        self.image = image
    }
    
    public var body: some View {
        self.image
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
    }
}
