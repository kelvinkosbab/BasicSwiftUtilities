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

import SwiftUI

/// Control if allow to dismiss the sheet by the user actions
/// - Drag down on the sheet on iPhone and iPad
/// - Tap outside the sheet on iPad
/// No impact to dismiss programatically (by calling "presentationMode.wrappedValue.dismiss()")
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 13.0, tvOS 13.0, *)
struct MbModalHackView: UIViewControllerRepresentable {
    var dismissable: () -> Bool = { false }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MbModalHackView>) -> UIViewController {
        MbModalViewController(dismissable: self.dismissable)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 13.0, tvOS 13.0, *)
extension MbModalHackView {
    private final class MbModalViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
        let dismissable: () -> Bool
        
        init(dismissable: @escaping () -> Bool) {
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
        }
        else {
            return self
        }
    }
}

/// make the call the SwiftUI style:
/// `view.allowAutDismiss(...)`
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 13.0, tvOS 13.0, *)
public extension View {
    
    /// Control if allow to dismiss the sheet by the user actions
    func allowAutoDismiss(_ dismissable: @escaping () -> Bool) -> some View {
        self
            .background(MbModalHackView(dismissable: dismissable))
    }
    
    /// Control if allow to dismiss the sheet by the user actions
    func allowAutoDismiss(_ dismissable: Bool) -> some View {
        self
            .background(MbModalHackView(dismissable: { dismissable }))
    }
}

// MARK: - Preview

#if DEBUG

@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(iOS 13.0, tvOS 13.0, *)
struct AllowAutoDismiss_Previews: PreviewProvider {
    
    struct ContentView: View {
        @State private var presenting = false
        
        var body: some View {
            VStack {
                Button {
                    presenting = true
                } label: {
                    Text("Present")
                }
            }
            .sheet(isPresented: $presenting) {
                ModalContent()
                    .allowAutoDismiss { false }
                    // or
                    // .allowAutoDismiss(false)
            }
        }
    }

    struct ModalContent: View {
        @Environment(\.presentationMode) private var presentationMode
        
        var body: some View {
            VStack {
                Text("Hello")
                    .padding()
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Dismiss")
                }
            }
        }
    }
    
    static var previews: some View {
        ContentView()
    }
}

#endif
#endif
#endif
