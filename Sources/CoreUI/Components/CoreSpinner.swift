//
//  CoreSpinner.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreActivityIndicator

@available(iOS 14.0, macOS 13.0, tvOS 14.0, watchOS 7.0, *)
private struct SwiftUISpinner : View {
    
    let style: CoreSpinner.Style
    
    var body: some View {
        VStack {
            switch self.style {
            case .color(color: let color):
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
            default:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}

/// A view that shows a spinner to indicate processing or loading. This spinner does not indicate a progress value and only represents
/// indeterminate progress.
///
/// Use a spinner view to show that a task is making progress towards
/// completion. A progress view can show both determinate (percentage complete)
/// and indeterminate (progressing or not) types of progress.
///
///     var body: some View {
///         ProgressView()
///     }
///
/// You can customize the appearance and interaction of spinner views by passing a color.
///
///     var body: some View {
///         ProgressView(color: .blue)
///     }
///
/// Also keep in mind of the `AppColors` which allows the spinner to reflect your app's custom color scheme.
///
///     var body: some View {
///         ProgressView(color: AppColors.appTintColor)
///     }
///
/// If you wish to show determinate progress use the `ProgressView` component.
@available(iOS 14.0, macOS 13.0, tvOS 14.0, watchOS 7.0, *)
public struct CoreSpinner : View {
    
    enum Style {
        
        /// Represents the system default.
        case `default`
        
        /// Represents a spinner with the provided color.
        case color(color: Color)
    }
    
    let style: Style
    
    public init() {
        self.style = .default
    }
    
    /// Constructor.
    ///
    /// - Parameter color: The color of the spinner.
    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public init(
        color: Color
    ) {
        self.style = .color(color: color)
    }
    
    /// Constructor.
    ///
    /// - Parameter hex: Represents a color's hex value. For example `0x44DAA7` is the value
    /// for hex color `#44DAA7`.
    public init(
        hexColor: Int
    ) {
        self.init(color: Color.hex(hexColor))
    }
    
    public var body: some View {
        SwiftUISpinner(style: self.style)
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 14.0, macOS 13.0, tvOS 14.0, watchOS 7.0, *)
struct CoreSpinner_Previews: PreviewProvider {
    
    static var previews: some View {
        
        List {
            CoreSpinner()
            CoreSpinner(color: .blue)
            CoreSpinner(color: .green)
            CoreSpinner(color: .red)
        }
        .previewDisplayName("CoreActivityIndicator")
    }
}

#endif
