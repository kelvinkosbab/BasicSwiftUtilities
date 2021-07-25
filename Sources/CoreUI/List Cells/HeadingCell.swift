//
//  HeadingCell.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - HeadingCell

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct HeadingCell : View {
    
    public var heading: String
    
    public init(_ heading: String) {
        self.heading = heading
    }
    
    public var body: some View {
        Text(self.heading)
            .bodyBoldStyle()
            .padding(.vertical, Spacing.base)
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct Previews: PreviewProvider {
    
    static let titles = [ "Hello World one",
                          "Hello World two",
                          "Hello World three",
                          "Hello World four",
                          "Hello World five" ]
    
    static var previews: some View {
        List(self.titles, id: \.self) { title in
            HeadingCell(title)
        }
    }
}

#endif
