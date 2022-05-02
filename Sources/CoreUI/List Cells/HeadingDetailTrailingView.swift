//
//  HeadingDetailTrailingView.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - HeadingDetailTrailingView

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public struct HeadingDetailTrailingView<Content : View> : View {
    
    public var heading: String
    public var detail: String
    public let trailing: Content
    
    public init(heading: String, detail: String, @ViewBuilder trailing: () -> Content) {
        self.heading = heading
        self.detail = detail
        self.trailing = trailing()
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            HeadingDetailCell(heading: self.heading, detail: self.detail)
            Spacer()
            self.trailing
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
struct HeadingDetailTrailingView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            HeadingDetailTrailingView(heading: "Hello World one",
                                      detail: "Hello World one") {
                Text("tmp")
                    .bodyStyle()
            }
            
            HeadingDetailTrailingView(heading: "Hello World one",
                                      detail: "Hello World one") {
                Button("Something") {
                    // do nothing
                }
            }
            HeadingDetailTrailingView(heading: "Hello World one",
                                      detail: "Hello World one") {
                EmptyView()
            }
        }
    }
}

#endif
