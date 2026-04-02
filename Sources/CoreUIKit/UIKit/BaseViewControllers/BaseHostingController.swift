//
//  BaseHostingController.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(tvOS)
#if !os(watchOS)

import UIKit
import SwiftUI

// MARK: - BaseHostingController

/// Defines a `UIViewController` for mounting a `SwiftUI.View`. This view controller also
/// conforms to ``PresentableController`` for simple controller presentation.
///
/// ```swift
/// let viewController = BaseHostingController.newViewController {
///      VStack {
///          Circle()
///              .fill(.blue)
///          Text("SwiftUI Content View Text")
///              .foregroundColor(.white)
///      }
/// }
/// ```
public class BaseHostingController<Content: View>: UIViewController, PresentableController {

    // MARK: - Static Accessors

    /// Creates a view controller which mounts the provided `SwiftUI.View`.
    ///
    /// ```swift
    /// let viewController = BaseHostingController.newViewController {
    ///      VStack {
    ///          Circle()
    ///              .fill(.blue)
    ///          Text("SwiftUI Content View Text")
    ///              .foregroundColor(.white)
    ///      }
    /// }
    /// ```
    public static func newViewController(contentView: Content) -> BaseHostingController {
        let viewController = BaseHostingController()
        viewController.contentView = contentView
        return viewController
    }

    // MARK: - PresentableController

    /// The mode used to present this controller.
    public var presentedMode: PresentationMode = .default
    /// The custom transitioning delegate, if any.
    public var presentationManager: UIViewControllerTransitioningDelegate?
    /// The first controller in the current presentation flow.
    public var currentFlowInitialController: PresentableController?

    // MARK: - Properties

    private var contentView: Content!

    private lazy var hostingController: UIHostingController = {
        return UIHostingController(rootView: self.contentView)
    }()

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.add(
            childViewController: self.hostingController,
            intoContainerView: self.view
        )
    }
}

#endif
#endif
#endif
