//
//  HeadingDetailCell.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - HeadingDetailCell

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
public struct HeadingDetailCell: View {
    
    public let heading: String
    public let detail: String
    public let detailTextColor: Color
    
    public init(heading: String,
                detail: String,
                detailTextColor: Color = .gray) {
        self.heading = heading
        self.detail = detail
        self.detailTextColor = detailTextColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(self.heading)
                .headingBoldStyle()
            Text(self.detail)
                .bodyStyle()
                .foregroundColor(self.detailTextColor)
        }
        .padding(.vertical, Spacing.small)
    }
}

// MARK: - Preview
    
#if DEBUG

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
struct HeadingDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            HeadingDetailCell(heading: "Heading one",
                              detail: "Detail one")
            HeadingDetailCell(heading: "Heading two",
                              detail: "Detail two")
        }
    }
}

#endif
