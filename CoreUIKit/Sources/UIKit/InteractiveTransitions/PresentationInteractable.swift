//
//  PresentationInteractable.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

public import UIKit

// MARK: - PresentationInteractable

@MainActor
public protocol PresentationInteractable: AnyObject {
    var presentationInteractiveViews: [UIView] { get }
}

// MARK: - DismissInteractable

@MainActor
public protocol DismissInteractable: AnyObject {
    var dismissInteractiveViews: [UIView] { get }
}

#endif
#endif
