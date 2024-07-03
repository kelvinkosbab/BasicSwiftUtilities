//
//  HexColorsTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import XCTest
@testable import CoreUI

// MARK: - HexColorsTests

final class HexColorsTests: XCTestCase {

    func testHexColorValueAndStringConversion() {
        for value in 0...0xFFFFFF {
            let hexString = String(value, radix: 16).uppercased()
            let intHexColor = HexColor(hex: value)
            let stringHexColor = HexColor(hex: hexString)
            XCTAssertEqual(
                intHexColor.hexValue,
                stringHexColor?.hexValue
            )
            XCTAssertEqual(
                intHexColor.hexString,
                hexString
            )
        }
    }

    func testValidHexStrings() {
        let hex = "D3004C"
        let validHexStrings = [
            hex,
            "#\(hex)",
            "##\(hex)",
            " #\(hex) ",
            "\t#\(hex)\t",
            "\n#\(hex)\n",
            "0x\(hex)"
        ]
        for testString in validHexStrings {
            let color = HexColor(hex: testString)
            XCTAssertEqual(
                color?.hexValue,
                0xD3004C
            )
        }
    }

    func testInvalidHexStrings() {
        let validHexStrings = [
            "1234567", // Too many valid characters
            "GGGGGG",  // Correct length but invalid hex character
            "D3004F."  // Too many characters due to invalid character
        ]
        for testString in validHexStrings {
            let color = HexColor(hex: testString)
            XCTAssert(color == nil)
        }
    }
}
