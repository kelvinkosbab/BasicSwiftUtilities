//
//  SwipeActions.swift
//
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

/// An edge on the horizontal axis.
///
/// Use a horizontal edge for tasks like setting a swipe action with the
/// ``View/swipeActions(edge:allowsFullSwipe:content:)``
/// view modifier. The positions of the leading and trailing edges
/// depend on the locale chosen by the user.
public enum Edge {

    /// The leading edge.
    case leading
    
    /// The trailing edge.
    case trailing
    
    @available(iOS 15, *)
    var horizontalEdge: HorizontalEdge {
        switch self {
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
}

@available(iOS 13, *)
private struct SwipeModifier<T>: ViewModifier where T : View {
    
    private let edge: Edge
    private let allowsFullSwipe: Bool
    private let swipeActions: () -> T
    
    public init(edge: Edge,
                allowsFullSwipe: Bool,
                swipeActions: @escaping () -> T) {
        self.edge = edge
        self.allowsFullSwipe = allowsFullSwipe
        self.swipeActions = swipeActions
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .swipeActions(edge: self.edge.horizontalEdge,
                              allowsFullSwipe: self.allowsFullSwipe,
                              content: self.swipeActions)
        } else {
            content // TODO
        }
    }
}

// MARK: - Modifier

@available(iOS 13, *)
public extension View {
    
    func swipe<T>(edge: Edge = .trailing,
                  allowsFullSwipe: Bool = true,
                  swipeActions: @escaping () -> T) -> some View where T : View {
        self.modifier(SwipeModifier(edge: edge,
                                    allowsFullSwipe: allowsFullSwipe,
                                    swipeActions: swipeActions))
    }
}
