//
//  HexColorsTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
@testable import CoreUI

// MARK: - HexColorsTests

@Suite("HexColor")
struct HexColorsTests {

    @Test("Hex value and string conversion are consistent for 6-digit values")
    func hexColorValueAndStringConversion() {
        // HexColor(hex: String) requires exactly 6 hex characters, so we test from 0x100000
        for value in 0x100000...0xFFFFFF {
            let hexString = String(value, radix: 16).uppercased()
            let intHexColor = HexColor(hex: value)
            let stringHexColor = HexColor(hex: hexString)
            #expect(intHexColor.hexValue == stringHexColor?.hexValue)
            #expect(intHexColor.hexString == hexString)
        }
    }

    @Test("Valid hex strings are parsed correctly",
          arguments: ["D3004C", "#D3004C", "##D3004C", " #D3004C ", "\t#D3004C\t", "\n#D3004C\n", "0xD3004C"])
    func validHexStrings(testString: String) {
        let color = HexColor(hex: testString)
        #expect(color?.hexValue == 0xD3004C)
    }

    @Test("Invalid hex strings return nil",
          arguments: ["1234567", "GGGGGG", "D3004F."])
    func invalidHexStrings(testString: String) {
        let color = HexColor(hex: testString)
        #expect(color == nil)
    }
}
