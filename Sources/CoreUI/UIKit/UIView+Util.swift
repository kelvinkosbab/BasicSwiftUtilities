//
//  UIView+Util.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import UIKit

// MARK: - UIView

public enum RelativeLayoutType {
    case safeArea
    case view
}

public extension UIView {
    
    @available(iOS 11.0, *)
    func addToContainer(_ containerView: UIView,
                               atIndex index: Int? = nil,
                               topMargin: CGFloat = 0,
                               bottomMargin: CGFloat = 0,
                               leadingMargin: CGFloat = 0,
                               trailingMargin: CGFloat = 0,
                               relativeLayoutType: RelativeLayoutType = .view) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = containerView.bounds
        
        if let index = index {
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
            let top = NSLayoutConstraint(item: self,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: containerView,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: topMargin)
            let bottom = NSLayoutConstraint(item: containerView,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .bottom,
                                            multiplier: 1,
                                            constant: bottomMargin)
            let leading = NSLayoutConstraint(item: self,
                                             attribute: .leading,
                                             relatedBy: .equal,
                                             toItem: containerView,
                                             attribute: .leading,
                                             multiplier: 1,
                                             constant: leadingMargin)
            let trailing = NSLayoutConstraint(item: containerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: trailingMargin)
            containerView.addConstraints([ top, bottom, leading, trailing ])
        }
        
        containerView.layoutIfNeeded()
    }
    
    // MARK: - Rounding Corners
    
    // Simplified and adapted from https://stackoverflow.com/questions/29618760/create-a-rectangle-with-just-two-rounded-corners-in-swift/35621736#35621736
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
