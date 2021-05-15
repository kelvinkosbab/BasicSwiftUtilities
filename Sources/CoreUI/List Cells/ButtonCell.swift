//
//  ButtonCell.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - NavigationButton

@available(iOS 13, *)
public struct ButtonCell : View {
    
    public let title: String
    public let isDestructive: Bool
    private let action: () -> Void
    
    public init(_ title: String,
                isDestructive: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.isDestructive = isDestructive
        self.action = action
    }
    
    public var body: some View {
        HStack {
            Spacer()
            CoreButton(self.title, isDestructive: self.isDestructive, action: self.action)
            Spacer()
        }
    }
}

// MARK: - NavigationButtonCell

@available(iOS 13, *)
public struct NavigationButtonCell<Destination> : View where Destination : View {
    
    public let title: String
    public let isDestructive: Bool
    private let destination: Destination
    
    public init(_ title: String,
                isDestructive: Bool = false,
                @ViewBuilder destination: () -> Destination) {
        self.title = title
        self.isDestructive = isDestructive
        self.destination = destination()
    }
    
    public var body: some View {
        NavigationLink(destination: self.destination) {
            HStack {
                Spacer()
                CoreButton(self.title, isDestructive: self.isDestructive, action: {})
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13, *)
private struct Previews: PreviewProvider {
    
    static let titles = [ "Hello World one",
                          "Hello World two",
                          "Hello World three",
                          "Hello World four",
                          "Hello World five" ]
    
    static var previews: some View {
        List(self.titles, id: \.self) { title in
            VStack {
                ButtonCell(title, action: {})
                ButtonCell(title, isDestructive: true, action: {})
                NavigationButtonCell(title) {
                    Text("hi")
                }
                NavigationButtonCell(title, isDestructive: true) {
                    Text("hi")
                }
            }
        }
    }
}

#endif
