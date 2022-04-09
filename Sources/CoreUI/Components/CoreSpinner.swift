//
//  CoreSpinner.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreActivityIndicator

@available(iOS 14.0, macOS 12, *)
private struct SwiftUISpinner : View {
    
    let style: CoreSpinner.Style
    
    var body: some View {
        VStack {
            switch self.style {
            case .color(color: let color, uiColor: _):
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
            case .default:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}

#if !os(macOS)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private struct UIKitSpinner: UIViewRepresentable {
    
    let style: CoreSpinner.Style
    
    func makeUIView(context: UIViewRepresentableContext<UIKitSpinner>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.startAnimating()
        switch self.style {
        case .color(color: _, uiColor: let color):
            view.color = color
        case .default:
            break
        }
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<UIKitSpinner>) {
        // do nothing
    }
}
#endif

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
@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
public struct CoreSpinner : View {
    
    enum Style {
        case `default`
        case color(color: Color, uiColor: UIColor)
    }
    
    let style: Style
    
    public init() {
        self.style = .default
    }
    
    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public init(
        color: Color
    ) {
        self.style = .color(color: color, uiColor: UIColor(color))
    }
    
    public init(
        uiColor: UIColor = AppColors.appTintUIColor
    ) {
        self.style = .color(color: Color(uiColor), uiColor: uiColor)
    }
    
    public var body: some View {
        #if !os(macOS)
        if #available(iOS 14.0, *) {
            SwiftUISpinner(style: self.style)
        } else {
            UIKitSpinner(style: self.style)
        }
        #else
        SwiftUISpinner(style: self.style)
        #endif
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
struct CoreSpinner_Previews: PreviewProvider {
    
    static var previews: some View {
        
        List {
            CoreSpinner()
            if #available(iOS 14.0, *) {
                CoreSpinner(color: .blue)
                CoreSpinner(color: .green)
                CoreSpinner(color: .red)
            }
            CoreSpinner(uiColor: .blue)
            CoreSpinner(uiColor: .green)
            CoreSpinner(uiColor: .red)
        }
        .previewDisplayName("CoreActivityIndicator")
    }
}

#endif
