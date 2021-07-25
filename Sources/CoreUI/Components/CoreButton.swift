//
//  CoreButton.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreButtonStyle

@available(iOS 13, *)
public struct CoreButtonStyle : ButtonStyle {
    
    private let fillParentWidth: Bool
    private let foregroundColor: Color
    
    public init(fillParentWidth: Bool = false, foregroundColor: Color) {
        self.fillParentWidth = fillParentWidth
        self.foregroundColor = foregroundColor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(self.foregroundColor)
            .bodyBoldStyle()
            .multilineTextAlignment(.center)
            .padding()
            .padding(.horizontal, Spacing.base)
            .modifier(MaxWidthModifier(fillParentWidth: self.fillParentWidth))
    }
}

// MARK: - CoreButton

@available(iOS 13, *)
public struct CoreButton<S> : View where S : StringProtocol {
    
    private let title: S
    private let foregroundColor: Color
    private let action: () -> Void
    
    public init(_ title: S,
                foregroundColor: Color,
                action: @escaping () -> Void) {
        self.title = title
        self.foregroundColor = foregroundColor
        self.action = action
    }
    
    public init(_ title: S,
                isDestructive: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.foregroundColor = isDestructive ? AppColors.appDestructiveColor : AppColors.appTintColor
        self.action = action
    }
    
    public var body: some View {
        Button(self.title, action: self.action)
            .buttonStyle(CoreButtonStyle(foregroundColor: self.foregroundColor))
    }
}

// MARK: - CoreNavigationButton

@available(iOS 13, *)
public struct CoreNavigationButton<S, Destination> : View where S : StringProtocol, Destination : View {
    
    private let title: S
    private let foregroundColor: Color
    private let destination: Destination
    
    public init(_ title: S,
                foregroundColor: Color,
                destination: Destination) {
        self.title = title
        self.foregroundColor = foregroundColor
        self.destination = destination
    }
    
    public init(_ title: S,
                isDestructive: Bool = false,
                destination: Destination) {
        self.title = title
        self.foregroundColor = isDestructive ? AppColors.appDestructiveColor : AppColors.appTintColor
        self.destination = destination
    }
    
    public var body: some View {
        NavigationLink(self.title, destination: self.destination)
            .buttonStyle(CoreButtonStyle(foregroundColor: self.foregroundColor))
    }
}

// MARK: - CoreRoundButton

@available(iOS 13, *)
public struct CoreRoundButton<S> : View where S : StringProtocol{
    
    private let title: S
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let fillParentWidth: Bool
    private let action: () -> Void
    
    public init(_ title: S,
                backgroundColor: Color,
                foregroundColor: Color,
                fillParentWidth: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.fillParentWidth = fillParentWidth
        self.action = action
    }
    
    public init(_ title: S,
                isDestructive: Bool = false,
                foregroundColor: Color = .white,
                fillParentWidth: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.backgroundColor = isDestructive ? AppColors.appDestructiveColor : AppColors.appTintColor
        self.foregroundColor = foregroundColor
        self.fillParentWidth = fillParentWidth
        self.action = action
    }
    
    public var body: some View {
        Button(self.title, action: self.action)
            .buttonStyle(CoreButtonStyle(fillParentWidth: self.fillParentWidth, foregroundColor: self.foregroundColor))
            .background(self.backgroundColor)
            .clipShape(Capsule())
    }
}

// MARK: - CoreNavigationRoundButton

@available(iOS 13, *)
public struct CoreNavigationRoundButton<S, Destination> : View where S : StringProtocol, Destination : View {
    
    private let title: S
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let fillParentWidth: Bool
    private let destination: Destination
    
    public init(_ title: S,
                backgroundColor: Color,
                foregroundColor: Color,
                fillParentWidth: Bool = false,
                destination: Destination) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.fillParentWidth = fillParentWidth
        self.destination = destination
    }
    
    public init(_ title: S,
                isDestructive: Bool = false,
                foregroundColor: Color = .white,
                fillParentWidth: Bool = false,
                destination: Destination) {
        self.title = title
        self.backgroundColor = isDestructive ? AppColors.appDestructiveColor : AppColors.appTintColor
        self.foregroundColor = foregroundColor
        self.fillParentWidth = fillParentWidth
        self.destination = destination
    }
    
    public var body: some View {
        NavigationLink(self.title, destination: self.destination)
            .buttonStyle(CoreButtonStyle(fillParentWidth: self.fillParentWidth, foregroundColor: self.foregroundColor))
            .background(self.backgroundColor)
            .clipShape(Capsule())
    }
}

// MARK: - MaxWidthModifier

@available(iOS 13, *)
private struct MaxWidthModifier : ViewModifier {
    
    private let fillParentWidth: Bool
    
    init(fillParentWidth: Bool) {
        self.fillParentWidth = fillParentWidth
    }
    
    func body(content: Content) -> some View {
        if self.fillParentWidth {
            content
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13, *)
private struct Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            VStack {
                self.simpleButtons
            }
        }
        
        NavigationView {
            VStack {
                self.roundedButtons
            }
        }
        
        NavigationView {
            VStack {
                self.wideRoundButtons
            }
        }
    }
    
    static var simpleButtons: some View {
        VStack(spacing: 10) {
            
            CoreButton("Hello World") {}
            
            CoreNavigationButton("Hello World", destination: Text("hi"))
            
            CoreButton("Hello World", isDestructive: true) {}
            
            CoreNavigationButton("Hello World", isDestructive: true, destination: Text("hi"))
        }
    }
    
    static var roundedButtons: some View {
        VStack(spacing: 10) {
            
            CoreRoundButton("Hello World") {}
            
            CoreNavigationRoundButton("Hello World",
                                      destination: Text("hi"))
            
            CoreRoundButton("Hello World", isDestructive: true) {}
            
            CoreNavigationRoundButton("Hello World",
                                      isDestructive: true,
                                      destination: Text("hi"))
        }
    }
    
    static var wideRoundButtons: some View {
        VStack(spacing: 10) {
            
            CoreRoundButton("Hello World",
                            fillParentWidth: true) {}
            
            CoreNavigationRoundButton("Hello World",
                                      fillParentWidth: true,
                                      destination: Text("hi"))
            
            CoreRoundButton("Hello World",
                            isDestructive: true,
                            fillParentWidth: true) {}
            
            CoreNavigationRoundButton("Hello World",
                                      isDestructive: true,
                                      fillParentWidth: true,
                                      destination: Text("hi"))
        }
    }
}

#endif
