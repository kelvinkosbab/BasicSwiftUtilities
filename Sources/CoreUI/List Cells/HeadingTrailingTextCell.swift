//
//  HeadingTrailingTextCell.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - HeadingTrailingTextCell

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct HeadingTrailingTextCell: View {
    
    private var heading: String
    private var trailing: String
    private let tintColor: Color
    private var isAction: Bool
    
    public init(heading: String,
                trailing: String,
                tintColor: Color = AppColors.appTintColor,
                isAction: Bool = false) {
        self.heading = heading
        self.trailing = trailing
        self.tintColor = tintColor
        self.isAction = isAction
    }
    
    public var body: some View {
        HStack {
            Text(self.heading)
                .bodyBoldStyle()
            Spacer()
            if self.isAction {
                Text(self.trailing)
                    .bodyStyle()
                    .foregroundColor(self.tintColor)
            } else {
                Text(self.trailing)
                    .bodyStyle()
            }
            
        }
        .padding(.vertical, Spacing.small)
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct HeadingTrailingTextCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            HeadingTrailingTextCell(heading: "Hello World one",
                                    trailing: "Hello")
            HeadingTrailingTextCell(heading: "Hello World two",
                                    trailing: "Hello",
                                    isAction: true)
        }
    }
}

#endif
