//
//  UICollectionView+Util.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

extension UICollectionView {
    
    /// When embedding a collection view as a child view controller in a container view more configuration is
    /// necessary to get reordering to work properly. This should be called in segue or when programmatically
    /// adding this controller to another view controller.
    public func configureLongPressReordering() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleCollectionViewLongGesture(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    @objc internal func handleCollectionViewLongGesture(_ gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            
            guard let selectedIndexPath = self.indexPathForItem(at: gesture.location(in: self)) else {
                break
            }
            
            self.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case .changed:
            self.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view))
            
        case .ended:
            self.endInteractiveMovement()
            
        default:
            self.cancelInteractiveMovement()
        }
    }
}

#endif
#endif
