//
//  CoreBlurView.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreBlurView

@available(iOS 13, *)
public struct CoreBlurView<Content : View> : View {
    
    private let content: Content
    
    public init(@ViewBuilder builder: () -> Content) {
        self.content = builder()
    }
    
    public var body: some View {
        self.content
            .foregroundColor(.darkRed)
            .background(Color.white
                            .opacity(0.1)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(15.0))
                            
//            .background(Image(uiImage: UIImage.icTallyBokBlue!)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit).blurred())
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
