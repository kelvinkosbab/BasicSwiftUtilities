//
//  Searchable.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import SwiftUI

// MARK: - Searchable

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
private struct Searchable : ViewModifier {
    
    @Binding var text: String
    let placeholderText: String
    
    init(text: Binding<String>,
         placeholderText: String = "") {
        self._text = text
        self.placeholderText = placeholderText
    }
    
    private let searchBarHeight: CGFloat = 60
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .searchable(text: self.$text,
                            // TODO: Support SearchFieldPlacement
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: self.placeholderText)
        } else {
            ZStack(alignment: .top) {
                content
                
                self.searchBar
                    .padding(.horizontal, Spacing.base)
                    .frame(height: self.searchBarHeight)
                    .blurred(.systemUltraThinMaterial)
            }
        }
    }
    
    private var searchBar : some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField(self.placeholderText,
                          text: self.$text)
                    .foregroundColor(.primary)
            }
            .padding(Spacing.small)
            .foregroundColor(.primary)
            .background(Color(.systemBackground))
            .clipShape(Capsule())
        }
    }
}

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    func coreSearchable(text: Binding<String>,
                        placeholderText: String) -> some View {
        return self.modifier(Searchable(text: text, placeholderText: placeholderText))
    }
}

#endif
