//
//  SFSymbolTester.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI
import CoreUI

// MARK: - SFSymbolTester

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
public struct SFSymbolTester : View {
    
    public enum SFImage {
        case custom(_ named: String)
        case system(_ systemName: String)
        
        var image: Image {
            switch self {
            case .custom(let name):
                return Image(name)
            case .system(let systemName):
                return Image(systemName: systemName)
            }
        }
    }
    
    @State var searchText = "circles.hexagongrid"
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                self.createColumn(image: SFImage.system(self.searchText).image, font: .system(size: 16))
                self.createColumn(image: SFImage.system(self.searchText).image, font: .system(size: 20))
                self.createColumn(image: SFImage.system(self.searchText).image, font: .system(size: 28))
            }
        }
        .coreSearchable(text: self.$searchText, placeholderText: "SF System Image Name...")
    }
    
    private func createColumn(image: Image, font: Font) -> some View {
        VStack(spacing: 20) {
            image
                .font(font.weight(.ultraLight))
                .foregroundColor(.blue)
            image
                .font(font.weight(.thin))
                .foregroundColor(.blue)
            image
                .font(font.weight(.light))
                .foregroundColor(.blue)
            image
                .font(font.weight(.regular))
                .foregroundColor(.blue)
            image
                .font(font.weight(.medium))
                .foregroundColor(.blue)
            image
                .font(font.weight(.medium))
                .foregroundColor(.blue)
            image
                .font(font.weight(.semibold))
                .foregroundColor(.blue)
            image
                .font(font.weight(.bold))
                .foregroundColor(.blue)
            image
                .font(font.weight(.heavy))
                .foregroundColor(.blue)
            image
                .font(font.weight(.black))
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
struct SFSymbolTester_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            SFSymbolTester()
        }
    }
}

#endif
