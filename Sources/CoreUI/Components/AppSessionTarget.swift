//
//  AppSessionTarget.swift
//
//  Created by Kelvin Kosbab on 8/16/21.
//

import Foundation

/// For apps that have multiple scenes/windows additional Toast Targets can be defined. When showing a toast
/// a particular scene can be selected for showing the toast.
public struct AppSessionTarget: OptionSet, Hashable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
    
    public static func == (lhs: AppSessionTarget, rhs: AppSessionTarget) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public static let primary = AppSessionTarget(rawValue: 1 << 0)
}
