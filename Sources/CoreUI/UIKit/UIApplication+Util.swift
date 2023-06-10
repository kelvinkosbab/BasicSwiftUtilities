//
//  UIApplication+Util.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

public extension UIApplication {
    
    /// The release or version number of the bundle.
    ///
    /// This key is a user-visible string for the version of the bundle. The required format is three period-separated integers, such as 10.14.1. The string can only contain numeric characters (0-9) and periods.
    ///
    /// Each integer provides information about the release in the format [Major].[Minor].[Patch]:
    /// - Major: A major revision number.
    /// - Minor: A minor revision number.
    /// - Patch: A maintenance release number.
    ///
    /// This key is used throughout the system to identify the version of the bundle.
    var shortVersionString: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    /// The build version that identifies an iteration of the bundle.
    ///
    /// This key is a machine-readable string composed of one to three period-separated integers, such as 10.14.1. The string can only contain numeric characters (0-9) and periods.
    ///
    /// Each integer provides information about the bundle version in the format [Major].[Minor].[Patch]:
    /// - Major: A major revision number.
    /// - Minor: A minor revision number.
    /// - Patch: A maintenance release number.
    ///
    /// You can include more integers but the system ignores them.
    ///
    /// You can also abbreviate the version by using only one or two integers, where missing integers in the format are interpreted as zeros. For example, 0 specifies 0.0.0, 10 specifies 10.0.0, and 10.5 specifies 10.5.0.
    ///
    /// This key is required by the App Store and is used throughout the system to identify your app's released or unreleased build. For macOS apps, increment the version number before you distribute a build.
    var bundleVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}

#endif
#endif
