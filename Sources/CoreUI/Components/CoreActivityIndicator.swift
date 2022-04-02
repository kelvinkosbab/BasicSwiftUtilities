//
//  CoreActivityIndicator.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreActivityIndicator

@available(iOS 14.0, macOS 12, *)
private struct SwiftUIActivityIndicator : View {
    
    private let tintColor: Color
    
    init(tintColor: Color = AppColors.appTintColor) {
        self.tintColor = tintColor
    }
    
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: self.tintColor))
        }
    }
}

#if !os(macOS)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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
#endif

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
public struct CoreActivityIndicator : View {
    
    public init() {}
    
    public var body: some View {
        #if !os(macOS)
        if #available(iOS 14.0, *) {
            SwiftUIActivityIndicator()
        } else {
            UIKitActivityIndicator(isAnimating: true, style: .large)
        }
        #else
        SwiftUIActivityIndicator()
        #endif
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
struct Activity_Previews: PreviewProvider {
    
    static var previews: some View {
        if #available(iOS 14.0, *) {
            SwiftUIActivityIndicator()
        } else {
            Circle()
        }
    }
}

#endif
