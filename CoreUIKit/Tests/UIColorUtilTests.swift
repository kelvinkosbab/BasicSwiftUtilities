//
//  UIColorUtilTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import Testing
import UIKit
@testable import CoreUIKit

// MARK: - UIColor Util Tests

@Suite("UIColor Utility Tests")
struct UIColorUtilTests {

    // MARK: - HSB Components

    @Test("HSB components for a known color")
    func hsbComponents() {
        let color = UIColor.red
        #expect(color.hsbHue >= 0)
        #expect(color.hsbSaturation > 0)
        #expect(color.hsbBrightness > 0)
        #expect(color.hsbAlpha == 1.0)
    }

    // MARK: - RGB Components

    @Test("RGB components for red")
    func rgbComponentsRed() {
        let color = UIColor.red
        #expect(color.rgbRed == 255)
        #expect(color.rgbGreen == 0)
        #expect(color.rgbBlue == 0)
        #expect(color.rgbAlpha == 1.0)
    }

    @Test("RGB components for custom color")
    func rgbComponentsCustom() {
        let color = UIColor(red: 0.5, green: 0.25, blue: 0.75, alpha: 0.8)
        // Allow ±1 for floating point rounding
        #expect(abs(color.rgbRed - 128) <= 1)
        #expect(abs(color.rgbGreen - 64) <= 1)
        #expect(abs(color.rgbBlue - 191) <= 1)
        #expect(abs(color.rgbAlpha - 0.8) < 0.01)
    }

    // MARK: - rgbValue

    @Test("rgbValue packs ARGB correctly for opaque red")
    func rgbValueOpaqueRed() {
        let color = UIColor.red
        let value = color.rgbValue
        #expect(value != nil)
        // Opaque red: alpha=255, red=255, green=0, blue=0
        // (255 << 24) + (255 << 16) + (0 << 8) + 0
        #expect(value == 0xFF_FF_00_00)
    }

    // MARK: - rgbColor Factory

    @Test("rgbColor creates correct color from integer components")
    func rgbColorFactory() {
        let color = UIColor.rgbColor(red: 100, green: 150, blue: 200)
        // 100/255 ≈ 0.392, 150/255 ≈ 0.588, 200/255 ≈ 0.784
        #expect(abs(color.rgbRed - 100) <= 1)
        #expect(abs(color.rgbGreen - 150) <= 1)
        #expect(abs(color.rgbBlue - 200) <= 1)
    }

    // MARK: - Hex String

    @Test("hex string for known colors")
    func hexString() {
        let red = UIColor.red
        #expect(red.hex == "ff0000")

        let green = UIColor.green
        #expect(green.hex == "00ff00")

        let blue = UIColor.blue
        #expect(blue.hex == "0000ff")
    }

    // MARK: - color(hash:)

    @Test("color from hash extracts correct RGB")
    func colorFromHash() {
        let hash = 0xFF8040 // R=255, G=128, B=64
        let color = UIColor.color(hash: hash)
        #expect(color.rgbRed == 255)
        #expect(color.rgbGreen == 128)
        #expect(color.rgbBlue == 64)
    }

    // MARK: - init(hex:)

    @Test("init from hex string with hash prefix")
    func initHexWithHash() {
        let color = UIColor(hex: "#FF0000")
        #expect(color != nil)
        #expect(color?.rgbRed == 255)
        #expect(color?.rgbGreen == 0)
        #expect(color?.rgbBlue == 0)
    }

    @Test("init from hex string without hash prefix")
    func initHexWithoutHash() {
        let color = UIColor(hex: "00FF00")
        #expect(color != nil)
        #expect(color?.rgbRed == 0)
        #expect(color?.rgbGreen == 255)
        #expect(color?.rgbBlue == 0)
    }

    @Test("init from hex string with custom alpha")
    func initHexWithAlpha() {
        let color = UIColor(hex: "0000FF", alpha: 0.5)
        #expect(color != nil)
        #expect(abs((color?.rgbAlpha ?? 0) - 0.5) < 0.01)
    }

    @Test("init from invalid hex string returns nil")
    func initHexInvalid() {
        #expect(UIColor(hex: "ZZZ") == nil)
        #expect(UIColor(hex: "FF") == nil)
        #expect(UIColor(hex: "") == nil)
    }
}

// MARK: - UIColor Hex Extension Tests

@Suite("UIColor Hex Extension Tests")
struct UIColorHexExtensionTests {

    @Test("UIColor.hex creates correct color")
    func hexFactory() {
        let color = UIColor.hex(0xFF0000)
        #expect(color.rgbRed == 255)
        #expect(color.rgbGreen == 0)
        #expect(color.rgbBlue == 0)
    }

    @Test("UIColor.hex with opacity")
    func hexFactoryWithOpacity() {
        let color = UIColor.hex(0x00FF00, opacity: 0.5)
        #expect(color.rgbGreen == 255)
        #expect(abs(color.rgbAlpha - 0.5) < 0.01)
    }
}

// MARK: - PresentationMode Tests

@Suite("PresentationMode Tests")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct PresentationModeTests {

    @Test("default presentation mode is formSheet")
    func defaultIsFormSheet() {
        let mode = PresentationMode.default
        switch mode {
        case .formSheet:
            break // expected
        default:
            Issue.record("Expected .formSheet but got \(mode)")
        }
    }

    @Test("show mode isShow returns true")
    func showIsShow() {
        let mode = PresentationMode.show
        #expect(mode.isShow)
    }

    @Test("formSheet mode isShow returns false")
    func formSheetIsNotShow() {
        let mode = PresentationMode.formSheet
        #expect(!mode.isShow)
    }

    @Test("crossDissolve mode isShow returns false")
    func crossDissolveIsNotShow() {
        let mode = PresentationMode.crossDissolve
        #expect(!mode.isShow)
    }
}

#endif
