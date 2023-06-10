//
//  BaseHostingController.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit
import SwiftUI

// MARK: - BaseHostingController

@available(iOS 13.0, *)
public class BaseHostingController<Content : View> : UIViewController, PresentableController {
    
    // MARK: - Static Accessors
    
    public static func newViewController(contentView: Content) -> BaseHostingController {
        let viewController = BaseHostingController()
        viewController.contentView = contentView
        return viewController
    }
    
    // MARK: - PresentableController
    
    public var presentedMode: PresentationMode = .default
    public var presentationManager: UIViewControllerTransitioningDelegate?
    public var currentFlowInitialController: PresentableController?
    
    // MARK: - Properties
    
    private var contentView: Content!
    
    private lazy var hostingController: UIHostingController = {
        return UIHostingController(rootView: self.contentView)
    }()
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.add(childViewController: self.hostingController, intoContainerView: self.view)
    }
    
    private func setupConstraints() {
        
        guard let view = self.hostingController.view else {
            return
        }
        
        view.translatesAutoresizingMaskIntoConstraints = true
        view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
}

#endif
#endif
