//
//  HeadingTrailingTextCell.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - HeadingTrailingTextCell

@available(iOS 13, *)
public struct HeadingTrailingTextCell: View {
    
    public var heading: String
    public var trailing: String
    public var isAction: Bool
    
    public init(heading: String, trailing: String, isAction: Bool = false) {
        self.heading = heading
        self.trailing = trailing
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
                    .foregroundColor(.tallyBokBlue)
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

@available(iOS 13, *)
private struct Previews: PreviewProvider {
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
