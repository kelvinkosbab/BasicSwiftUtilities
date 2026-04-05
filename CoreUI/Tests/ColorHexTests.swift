//
//  ColorHexTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import SwiftUI
@testable import CoreUI

// MARK: - ColorHexTests

@Suite("Color.hex")
struct ColorHexTests {

    @Test("Color.hex creates a color from hex integer")
    func colorFromHexInt() {
        // Just verify it doesn't crash and returns a Color
        let color = Color.hex(0xFF0000)
        #expect(type(of: color) == Color.self)
    }

    @Test("Color.hex with zero opacity is transparent")
    func colorWithZeroOpacity() {
        let color = Color.hex(0x00FF00, opacity: 0)
        #expect(type(of: color) == Color.self)
    }

    @Test("Color.hex with full opacity")
    func colorWithFullOpacity() {
        let color = Color.hex(0x0000FF, opacity: 1)
        #expect(type(of: color) == Color.self)
    }

    @Test("HexColor RGB components for known values")
    func hexColorRGBComponents() {
        let red = HexColor(hex: 0xFF0000)
        #expect(red.red == 1.0)
        #expect(red.green == 0.0)
        #expect(red.blue == 0.0)

        let green = HexColor(hex: 0x00FF00)
        #expect(green.red == 0.0)
        #expect(green.green == 1.0)
        #expect(green.blue == 0.0)

        let blue = HexColor(hex: 0x0000FF)
        #expect(blue.red == 0.0)
        #expect(blue.green == 0.0)
        #expect(blue.blue == 1.0)
    }

    @Test("HexColor white and black")
    func hexColorWhiteAndBlack() {
        let white = HexColor(hex: 0xFFFFFF)
        #expect(white.red == 1.0)
        #expect(white.green == 1.0)
        #expect(white.blue == 1.0)

        let black = HexColor(hex: 0x000000)
        #expect(black.red == 0.0)
        #expect(black.green == 0.0)
        #expect(black.blue == 0.0)
    }

    @Test("HexColor mixed color components")
    func hexColorMixedComponents() {
        // 0x80 = 128, 128/255 ≈ 0.502
        let color = HexColor(hex: 0x804020)
        #expect(abs(color.red - 128.0 / 255.0) < 0.001)
        #expect(abs(color.green - 64.0 / 255.0) < 0.001)
        #expect(abs(color.blue - 32.0 / 255.0) < 0.001)
    }
}
