//
//  CircleImage.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CircleImage

@available(iOS 13, *)
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
