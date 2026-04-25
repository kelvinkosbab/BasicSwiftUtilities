//
//  SwiftUI+allowAutoDismiss.swift
//
//  Copyright © Kozinga. All rights reserved.
//

//
//  Created by https://quickplan.app on 2020/11/8.
//

#if !os(macOS)
#if !os(watchOS)

public import SwiftUI

/// Control if allow to dismiss the sheet by the user actions
/// - Drag down on the sheet on iPhone and iPad
/// - Tap outside the sheet on iPad
/// No impact to dismiss programatically (by calling "presentationMode.wrappedValue.dismiss()")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct MbModalHackView: UIViewControllerRepresentable {
    var dismissable: @Sendable () -> Bool = { false }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MbModalHackView>) -> UIViewController {
        MbModalViewController(dismissable: self.dismissable)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
extension MbModalHackView {
    private final class MbModalViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
        let dismissable: @Sendable () -> Bool

        init(dismissable: @escaping @Sendable () -> Bool) {
            self.dismissable = dismissable
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)

            setup()
        }

        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            dismissable()
        }

        // set delegate to the presentation of the root parent
        private func setup() {
            guard let rootPresentationViewController = self.rootParent.presentationController, rootPresentationViewController.delegate == nil else { return }
            rootPresentationViewController.delegate = self
        }
    }
}

extension UIViewController {

    fileprivate var rootParent: UIViewController {
        if let parent = self.parent {
            return parent.rootParent
        } else {
            return self
        }
    }
}

/// Use these modifiers in SwiftUI to control sheet auto-dismiss behavior:
/// `view.allowAutoDismiss(...)`
@available(macOS, unavailable)
@available(watchOS, unavailable)
public extension View {

    /// Controls whether the user can dismiss a sheet via gestures (drag-down on iPhone/iPad,
    /// tap-outside on iPad).
    ///
    /// Programmatic dismissal via `dismiss()` or `presentationMode.dismiss()` is unaffected.
    ///
    /// - Parameter dismissable: A closure returning `true` to allow user dismissal,
    ///   `false` to prevent it. Re-evaluated on each gesture attempt.
    /// - Returns: A view that controls user-driven sheet dismissal.
    func allowAutoDismiss(_ dismissable: @escaping @Sendable () -> Bool) -> some View {
        self
            .background(MbModalHackView(dismissable: dismissable))
    }

    /// Controls whether the user can dismiss a sheet via gestures (drag-down on iPhone/iPad,
    /// tap-outside on iPad).
    ///
    /// Programmatic dismissal via `dismiss()` or `presentationMode.dismiss()` is unaffected.
    ///
    /// - Parameter dismissable: `true` to allow user dismissal, `false` to prevent it.
    /// - Returns: A view that controls user-driven sheet dismissal.
    func allowAutoDismiss(_ dismissable: Bool) -> some View {
        self
            .background(MbModalHackView(dismissable: { dismissable }))
    }
}

// MARK: - Preview

#if DEBUG

@available(macOS, unavailable)
@available(watchOS, unavailable)
private struct AllowAutoDismissPreviewContent: View {
    @State private var presenting = false

    var body: some View {
        VStack {
            Button("Present") {
                presenting = true
            }
        }
        .sheet(isPresented: $presenting) {
            AllowAutoDismissPreviewModal()
                .allowAutoDismiss { false }
        }
    }
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
private struct AllowAutoDismissPreviewModal: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Hello")
                .padding()

            Button("Dismiss") {
                dismiss()
            }
        }
    }
}

#Preview {
    AllowAutoDismissPreviewContent()
}

#endif
#endif
#endif
