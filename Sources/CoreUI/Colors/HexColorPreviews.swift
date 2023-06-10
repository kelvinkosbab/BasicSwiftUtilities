//
//  HexColors.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import SwiftUI
import UIKit

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
struct Color_Previews: PreviewProvider {
 
    /// In order to preview UIKit views in a `PreviewProvider` we must use
    /// `UIViewRepresentable`. This protocol can map a UIKit object into a SwiftUI View.
    #if !os(macOS)
    @available(macOS, unavailable)
    struct UIKitView: UIViewRepresentable {

        typealias UIViewType = UIView

        let hex: Int

        func makeUIView(context: UIViewRepresentableContext<UIKitView>) -> UIView {

            // Create and configure the UILabel.
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .hex(self.hex)
            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {
            // do nothing
        }
    }
    #endif
    
    static var mockHexColors: [Int] = [
        0x8250C4,
        0x5ECBC8,
        0x438FFF,
        0xEB5757,
        0x5B2071,
        0xEC5A96,
        0x73B761,
        0x4A588A,
        0xECC846,
        0x8D6FD1,
        0x95DABB,
        0x374649,
        0xFD625E,
        0xF2C80F,
        0x5F6B6D,
        0x8AD4EB,
        0xA66999,
        0x4A8DDC,
        0xF3C911,
        0xDC5B57,
        0x33AE81,
        0x95C8F0,
        0xDD915F,
        0x074650,
        0x009292,
        0xFE6DB6,
        0x480091,
        0xB66DFF,
        0xB5DAFE,
        0x118DFF,
        0xB73A3A,
        0x118DFF,
        0x750985,
        0xC83D95,
        0x1DD5EE,
        0x3049AD,
        0x325748,
        0x37A794,
        0x8B3D88,
        0xDD6B7F,
        0x77C4A8,
        0x426871,
        0xD2B04C,
        0x998F85,
        0xFFA500,
        0x107C10,
        0x499195,
        0x00ACFC,
        0xF18F49,
        0x326633,
        0xF1C716,
        0xD8D7BF,
        0xE87200,
        0xE13102,
        0xD3004C,
        0x9B0065,
        0x7D0033,
        0x5C0001,
        0x8BC7F7,
        0x46B3F3,
        0x0078ED,
        0x0050FB,
        0x064168,
        0x3049AD,
        0xC83D95,
        0x262476,
        0x234990,
        0x2F8AC3,
        0xFFC1CB,
        0xAE3535,
        0x094782,
        0x54B5FB,
        0x71C0A7,
        0x478F48,
        0x326633,
        0xF17925,
        0x004753,
        0xCCAA14,
        0xD82C20
    ]
 
    static var previews: some View {
        List {
            ForEach(self.mockHexColors, id: \.self) { hex in
                HStack {
                    Text("\(HexColor(hex: hex).hexString)")
                        .font(.system(
                            size: 12,
                            weight: .regular,
                            design: .monospaced
                        ))
                    Rectangle()
                        .foregroundColor(.hex(hex))
                }
            }
        }
        .previewDisplayName("SwiftUI and Color")
 
        #if !os(macOS)
        List {
            ForEach(self.mockHexColors, id: \.self) { hex in
                HStack {
                    Text("\(HexColor(hex: hex).hexString)")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                    UIKitView(hex: hex)
                }
            }
        }
        .previewDisplayName("UIKit and UIColor")
        #endif
    }
}
 
#endif

#endif
#endif
