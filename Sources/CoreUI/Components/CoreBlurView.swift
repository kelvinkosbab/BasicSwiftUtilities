//
//  CoreBlurView.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import SwiftUI

// MARK: - BlurredModifier

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
private struct BlurredModifier : ViewModifier {
    
    let style: UIBlurEffect.Style
    
    func body(content: Content) -> some View {
        content
            .background(Blur(style: self.style))
    }
}

/// Blurs the background of a view.
///
/// Usage:
/// ```
/// yourView
///     .blurred()
/// ```
///
/// - Parameter style: Blur effect style of the blurred view. See `UIBlurEffect.Style`
@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    func blurred(_ style: UIBlurEffect.Style) -> some View {
        return self.modifier(BlurredModifier(style: style))
    }
}

// MARK: - Blur

/// Usage:
/// ```
/// yourView
///     .background(Blur())
/// ```
@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
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

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
struct Blur_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollView {
            self.renderBasic()
            self.renderSystemMaterial()
            self.renderSystemMaterialLight()
            self.renderSystemMaterialDark()
        }
    }
    
    private static func renderBasic() -> some View {
        VStack(spacing: 10) {
            self.renderItem(.extraLight, text: "extraLight")
            self.renderItem(.light, text: "light")
            self.renderItem(.dark, text: "dark")
            self.renderItem(.regular, text: "regular")
            self.renderItem(.prominent, text: "prominent")
        }
    }
    
    private static func renderSystemMaterial() -> some View {
        VStack(spacing: 10) {
            self.renderItem(.systemUltraThinMaterial, text: "systemUltraThinMaterial")
            self.renderItem(.systemThinMaterial, text: "systemThinMaterial")
            self.renderItem(.systemMaterial, text: "systemMaterial")
            self.renderItem(.systemThickMaterial, text: "systemThickMaterial")
            self.renderItem(.systemChromeMaterial, text: "systemChromeMaterial")
        }
    }
    
    private static func renderSystemMaterialLight() -> some View {
        VStack(spacing: 10) {
            self.renderItem(.systemUltraThinMaterialLight, text: "systemUltraThinMaterialLight")
            self.renderItem(.systemThinMaterialLight, text: "systemThinMaterialLight")
            self.renderItem(.systemMaterialLight, text: "systemMaterialLight")
            self.renderItem(.systemThickMaterialLight, text: "systemThickMaterialLight")
            self.renderItem(.systemChromeMaterialLight, text: "systemChromeMaterialLight")
        }
    }
    private static func renderSystemMaterialDark() -> some View {
        VStack(spacing: 10) {
            self.renderItem(.systemUltraThinMaterialDark, text: "systemUltraThinMaterialDark")
            self.renderItem(.systemThinMaterialDark, text: "systemThinMaterialDark")
            self.renderItem(.systemMaterialDark, text: "systemMaterialDark")
            self.renderItem(.systemThickMaterialDark, text: "systemThickMaterialDark")
            self.renderItem(.systemChromeMaterialDark, text: "systemChromeMaterialDark")
        }
    }
    
    private static func renderItem(_ style: UIBlurEffect.Style, text: String) -> some View {
        HStack {
            ZStack {
                Image(systemName: "tray.and.arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 100, alignment: .center)
                Text(text)
                    .font(.body)
                    .foregroundColor(Color.white)
                    .padding()
                    .blurred(style)
                    .clipShape(Capsule())
            }
        }
    }
}

#endif
#endif
