//
//  SpacingTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
@testable import CoreUI

// MARK: - SpacingTests

@Suite("Spacing")
struct SpacingTests {

    @Test("Spacing constants have expected values")
    func spacingValues() {
        #expect(Spacing.tiny == 4)
        #expect(Spacing.small == 8)
        #expect(Spacing.base == 16)
        #expect(Spacing.large == 24)
        #expect(Spacing.xl == 32)
        #expect(Spacing.xxl == 40)
    }

    @Test("Spacing constants are in ascending order")
    func spacingOrder() {
        let values = [
            Spacing.tiny,
            Spacing.small,
            Spacing.base,
            Spacing.large,
            Spacing.xl,
            Spacing.xxl
        ]
        for i in 0..<(values.count - 1) {
            #expect(values[i] < values[i + 1])
        }
    }
}
