//
//  BlurViews.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI
import CoreUI

struct BlurViews : View {
    
    var body: some View {
        List {
            self.renderBasic()
            self.renderSystemMaterial()
            self.renderSystemMaterialLight()
            self.renderSystemMaterialDark()
        }
        .navigationTitle("Blur View Styles")
    }
    
    private func renderBasic() -> some View {
        VStack(spacing: 10) {
            self.renderItem(.extraLight, text: "extraLight")
            self.renderItem(.light, text: "light")
            self.renderItem(.dark, text: "dark")
            self.renderItem(.regular, text: "regular")
            self.renderItem(.prominent, text: "prominent")
        }
    }
    
    private func renderSystemMaterial() -> some View {
        VStack(spacing: 10) {
            self.renderItem(.systemUltraThinMaterial, text: "systemUltraThinMaterial")
            self.renderItem(.systemThinMaterial, text: "systemThinMaterial")
            self.renderItem(.systemMaterial, text: "systemMaterial")
            self.renderItem(.systemThickMaterial, text: "systemThickMaterial")
            self.renderItem(.systemChromeMaterial, text: "systemChromeMaterial")
        }
    }
    
    private func renderSystemMaterialLight() -> some View {
        VStack(spacing: 10) {
            self.renderItem(.systemUltraThinMaterialLight, text: "systemUltraThinMaterialLight")
            self.renderItem(.systemThinMaterialLight, text: "systemThinMaterialLight")
            self.renderItem(.systemMaterialLight, text: "systemMaterialLight")
            self.renderItem(.systemThickMaterialLight, text: "systemThickMaterialLight")
            self.renderItem(.systemChromeMaterialLight, text: "systemChromeMaterialLight")
        }
    }
    private func renderSystemMaterialDark() -> some View {
        VStack(spacing: 10) {
            self.renderItem(.systemUltraThinMaterialDark, text: "systemUltraThinMaterialDark")
            self.renderItem(.systemThinMaterialDark, text: "systemThinMaterialDark")
            self.renderItem(.systemMaterialDark, text: "systemMaterialDark")
            self.renderItem(.systemThickMaterialDark, text: "systemThickMaterialDark")
            self.renderItem(.systemChromeMaterialDark, text: "systemChromeMaterialDark")
        }
    }
    
    private func renderItem(_ style: UIBlurEffect.Style, text: String) -> some View {
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
