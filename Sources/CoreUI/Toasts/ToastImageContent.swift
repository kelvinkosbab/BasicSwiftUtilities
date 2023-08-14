//
//  ToastImageContent.swift
//  
//
//  Created by Kelvin Kosbab on 8/6/23.
//

#if !os(watchOS)

import Foundation
import SwiftUI

// MARK: - ToastImageContent

@available(iOS 13.0, macOS 12.0, tvOS 15.0, *)
public enum ToastImageContent : Equatable {
    
    case none
    case image(_ image: Image)
    case tintedImage(_ image: Image, _ tintColor: Color)
    
    @ViewBuilder
    func body() -> some View {
        switch self {
        case .none:
            Rectangle()
                .fill(.clear)
            
        case .image(let image):
            image
                .resizable()
            
        case .tintedImage(
            let image,
            let tintColor
        ):
            image
                .resizable()
                .foregroundColor(tintColor)
        }
    }
    
    public static func == (
        lhs: ToastImageContent,
        rhs: ToastImageContent
    ) -> Bool {
        switch lhs {
        case .none:
            switch rhs {
            case .none: return true
            default: return false
            }
            
        case .image:
            switch rhs {
            case .image: return true
            default: return false
            }
            
        case .tintedImage:
            switch rhs {
            case .tintedImage: return true
            default: return false
            }
        }
    }
}

#endif
