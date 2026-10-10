//
//  ToastTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

@testable import CoreUI
import SwiftUI
import Testing

// MARK: - ToastTests

@Suite("Toast")
@MainActor
struct ToastTests {

    @Test("Title + description toast keeps its leading and trailing content")
    func titleDescriptionToastKeepsLeadingAndTrailing() {
        // `ToastApi.show(title:description:leading:trailing:)` builds this
        // toast. It previously dropped both closures, so the icons never
        // rendered.
        let toast = Toast(
            shape: .capsule,
            title: "Saved",
            description: "Your changes were saved"
        ) {
            Image(systemName: "checkmark.circle")
        } trailing: {
            Image(systemName: "xmark")
        }

        #expect(toast.leading != nil)
        #expect(toast.trailing != nil)
    }

    @Test("Title + description toast without accessories has no leading or trailing content")
    func titleDescriptionToastHasNoAccessories() {
        let toast = Toast(
            shape: .roundedRectangle,
            title: "Saved",
            description: "Your changes were saved"
        )

        #expect(toast.leading == nil)
        #expect(toast.trailing == nil)
    }
}

#endif
