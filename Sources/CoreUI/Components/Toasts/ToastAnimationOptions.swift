//
//  ToastAnimationOptions.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import Foundation

// MARK: - ToastAnimationOptions

struct ToastAnimationOptions {
    
    let animationDuration: TimeInterval
    let prepareDuration: TimeInterval
    let showDuration: TimeInterval
    
    public init(animationDuration: TimeInterval = 0.2,
                prepareDuration: TimeInterval = 0.25,
                showDuration: TimeInterval = 1.0) {
        self.animationDuration = animationDuration
        self.prepareDuration = prepareDuration
        self.showDuration = showDuration
    }
}
