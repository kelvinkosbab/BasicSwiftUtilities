//
//  CoreBlurView.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - BlurredModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct BlurredModifier : ViewModifier {
    
    let style: UIBlurEffect.Style
    
    func body(content: Content) -> some View {
        content
            .background(Blur(style: self.style))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    func blurred(_ style: UIBlurEffect.Style = .systemUltraThinMaterial) -> some View {
        return self.modifier(BlurredModifier(style: style))
    }
}

// MARK: - Blur

/// Usage:
/// ```
/// yourView
///     .background(Blur())
/// ```
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct Blur: UIViewRepresentable {
    
    let style: UIBlurEffect.Style
    
    init(style: UIBlurEffect.Style) {
        self.style = style
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: self.style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: self.style)
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct Blur_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack {
            Image(systemName: "minus.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text("Hello World")
                .font(.largeTitle)
                .foregroundColor(Color.white)
                .padding()
                .cornerRadius(15)
                .blurred()
                
        }
    }
}

#endif

/// `THIS WORKS`
//ZStack {
//    Image(uiImage: UIImage.icTallyBokBlue!)
//        .resizable()
//        .aspectRatio(contentMode: .fit)
//    Text("Hello World")
//        .font(.largeTitle)
//        .foregroundColor(Color.white)
//        .padding()
//        .cornerRadius(15)
//        .background(Blur(style: .systemUltraThinMaterial).cornerRadius(15))
//
//}
