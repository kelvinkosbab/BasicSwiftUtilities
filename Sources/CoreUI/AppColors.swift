//
//  AppColors.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - AppColors

public struct AppColors {
    
    #if !os(macOS)
    public static var appTintUIColor: UIColor = .blue
    public static var appDestructiveUIColor: UIColor = .red
    #endif
    
    @available(iOS 13.0, *)
    public static var appTintColor: Color = .blue
    
    @available(iOS 13.0, *)
    public static var appDestructiveColor: Color = .red
}
