//
//  CoreBlurView.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreBlurView

@available(iOS 13, *)
public struct Blur: UIViewRepresentable {
    
    public let style: UIBlurEffect.Style
    
    public init(style: UIBlurEffect.Style = .systemUltraThinMaterial) {
        self.style = style
    }
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: self.style))
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: self.style)
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13, *)
private struct Previews: PreviewProvider {
    
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
                .background(Blur())
                
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
