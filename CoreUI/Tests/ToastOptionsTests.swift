//
//  ToastOptionsTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import Testing
import SwiftUI
@testable import CoreUI

// MARK: - ToastOptionsTests

@Suite("ToastOptions")
struct ToastOptionsTests {

    @Test("Default options are top capsule slide")
    func defaultOptions() {
        let options = ToastOptions()
        #expect(options.position == .top)
        #expect(options.shape == .capsule)
        #expect(options.animationStyle == .slide)
    }

    @Test("Slide animation duration is 0.75")
    func slideAnimationDuration() {
        let options = ToastOptions(style: .slide)
        #expect(options.animationDuration == 0.75)
    }

    @Test("Pop animation duration is 0.2")
    func popAnimationDuration() {
        let options = ToastOptions(style: .pop)
        #expect(options.animationDuration == 0.2)
    }

    @Test("Custom position and shape")
    func customPositionAndShape() {
        let options = ToastOptions(
            position: .bottom,
            shape: .roundedRectangle,
            style: .pop
        )
        #expect(options.position == .bottom)
        #expect(options.shape == .roundedRectangle)
        #expect(options.animationStyle == .pop)
    }

    @Test("Prepare and show durations are set")
    func durationsAreSet() {
        let options = ToastOptions()
        #expect(options.prepareDuration == 0.2)
        #expect(options.showDuration == 1.0)
    }
}

// MARK: - ToastStateTests

@Suite("ToastState")
struct ToastStateTests {

    @Test("None state should not be visible")
    func noneNotVisible() {
        let state = ToastState.none
        #expect(!state.shouldBeVisible)
    }

    @Test("Show state should be visible")
    func showIsVisible() {
        let state = ToastState.show(AnyView(EmptyView()))
        #expect(state.shouldBeVisible)
    }

    @Test("Prepare state should not be visible")
    func prepareNotVisible() {
        let state = ToastState.prepare(AnyView(EmptyView()))
        #expect(!state.shouldBeVisible)
    }

    @Test("Hiding state should not be visible")
    func hidingNotVisible() {
        let state = ToastState.hiding(AnyView(EmptyView()))
        #expect(!state.shouldBeVisible)
    }
}

#endif
