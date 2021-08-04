//
//  ToastContent.
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import SwiftUI

// MARK: - ToastContent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ToastContent {
    
    let title: String
    let description: String?
    let image: Image?
    let tintColor: Color?
    
    public init(title: String,
                description: String? = nil,
                image: Image? = nil,
                tintColor: Color? = nil) {
        self.title = title
        self.description = description
        self.image = image
        self.tintColor = tintColor
    }
}
