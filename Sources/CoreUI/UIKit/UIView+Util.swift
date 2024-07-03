//
//  UIView+Util.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

// MARK: - UIView

/// Defines how a view will be added to it's parent view.
public enum RelativeLayoutType {

    /// Child view will layout in reference to its parent view and also the safe area of the device / window.
    case safeArea

    /// Child view will layout in reference to only its parent view.
    case view
}

public extension UIView {

    /// Adds a view to a container parent view.
    ///
    /// - Parameter containerView: The parent container view which the view will be added to.
    /// - Parameter index: The index position in the parent view to add the view. `Default` is to add to the top of
    /// all child views.
    /// - Parameter topMargin: The space of the top spacing in reference to the parent view.
    /// - Parameter bottomMargin: The space of the bottom spacing in reference to the parent view.
    /// - Parameter leadingMargin: The space of the leading spacing in reference to the parent view.
    /// - Parameter trailingMargin: The space of the trailing spacing in reference to the parent view.
    /// - Parameter relativeLayoutType: Whelther the child view should layout according to only the parent view or the
    /// safe are margin of the device / window.
    func addToContainer(
        _ containerView: UIView,
        atIndex index: Int? = nil,
        topMargin: CGFloat = 0,
        bottomMargin: CGFloat = 0,
        leadingMargin: CGFloat = 0,
        trailingMargin: CGFloat = 0,
        relativeLayoutType: RelativeLayoutType = .view
    ) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = containerView.bounds

        if let index {
            containerView.insertSubview(self, at: index)
        } else {
            containerView.addSubview(self)
        }

        switch relativeLayoutType {
        case .safeArea:
            let guide = containerView.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                self.topAnchor.constraint(equalTo: guide.topAnchor, constant: topMargin),
                guide.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottomMargin),
                self.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: leadingMargin),
                guide.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailingMargin)
            ])
        case .view:
            let top = NSLayoutConstraint(
                item: self,
                attribute: .top,
                relatedBy: .equal,
                toItem: containerView,
                attribute: .top,
                multiplier: 1,
                constant: topMargin
            )
            let bottom = NSLayoutConstraint(
                item: containerView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: bottomMargin
            )
            let leading = NSLayoutConstraint(
                item: self,
                attribute: .leading,
                relatedBy: .equal,
                toItem: containerView,
                attribute: .leading,
                multiplier: 1,
                constant: leadingMargin
            )
            let trailing = NSLayoutConstraint(
                item: containerView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: trailingMargin
            )
            containerView.addConstraints([ top, bottom, leading, trailing ])
        }

        containerView.layoutIfNeeded()
    }

    // MARK: - Rounding Corners

    /// Utility function to round one or more corderns of a `UIView`.
    ///
    /// - Parameter corners: Corner(s) to round of the view.
    /// - Parameter radius: Corner radius to apply to the corner(s).
    /// 
    /// Simplified and adapted from [this StackOverflow post](https://stackoverflow.com/questions/29618760/create-a-rectangle-with-just-two-rounded-corners-in-swift/35621736#35621736).
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

#endif
#endif
