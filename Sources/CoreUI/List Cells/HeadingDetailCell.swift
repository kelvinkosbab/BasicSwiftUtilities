//
//  HeadingDetailCell.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - HeadingDetailCell

@available(iOS 13, *)
public struct HeadingDetailCell: View {
    
    public let heading: String
    public let detail: String
    
    public init(heading: String, detail: String) {
        self.heading = heading
        self.detail = detail
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(self.heading)
                .headingBoldStyle()
            Text(self.detail)
                .bodyStyle()
                .foregroundColor(.kozGray)
        }
        .padding(.vertical, Spacing.small)
    }
}

// MARK: - Preview
    
#if DEBUG

@available(iOS 13, *)
private struct Previews: PreviewProvider {
    static var previews: some View {
        List {
            HeadingDetailCell(heading: "Heading one", detail: "Detail one")
            HeadingDetailCell(heading: "Heading two", detail: "Detail two")
        }
    }
}

#endif
