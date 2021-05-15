//
//  CoreActivityIndicator.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreActivityIndicator

@available(iOS 14.0, *)
private struct SwiftUIActivityIndicator : View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .tallyBokBlue))
        }
    }
}

@available(iOS 13, *)
private struct UIKitActivityIndicator: UIViewRepresentable {
    
    var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<UIKitActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: self.style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<UIKitActivityIndicator>) {
        self.isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

@available(iOS 13, *)
public struct CoreActivityIndicator : View {
    
    public init() {}
    
    public var body: some View {
        if #available(iOS 14.0, *) {
            SwiftUIActivityIndicator()
        } else {
            UIKitActivityIndicator(isAnimating: true, style: .large)
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13, *)
private struct Previews: PreviewProvider {
    
    static var previews: some View {
        if #available(iOS 14.0, *) {
            SwiftUIActivityIndicator()
        } else {
            Circle()
        }
    }
}

#endif
