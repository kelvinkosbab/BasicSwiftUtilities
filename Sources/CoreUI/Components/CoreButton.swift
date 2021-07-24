//
//  CoreButton.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

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
        Button(action: self.action) {
            CoreButtonText(title: self.title,
                           foregroundColor: self.foregroundColor)
        }
        .buttonStyle(.automatic)
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
        NavigationLink(destination: self.destination) {
            CoreButtonText(title: self.title,
                           foregroundColor: self.foregroundColor)
        }
        .buttonStyle(.automatic)
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
        Button(action: self.action) {
            CoreRoundButtonContent(title: self.title,
                                   backgroundColor: self.backgroundColor,
                                   foregroundColor: self.foregroundColor,
                                   fillParentWidth: self.fillParentWidth)
                .background(self.backgroundColor)
        }
        .buttonStyle(.automatic)
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
        NavigationLink(destination: self.destination) {
            HStack {
                CoreRoundButtonContent(title: self.title,
                                       backgroundColor: self.backgroundColor,
                                       foregroundColor: self.foregroundColor,
                                       fillParentWidth: self.fillParentWidth)
                    .background(self.backgroundColor)
            }
        }
        .buttonStyle(.automatic)
        .clipShape(Capsule())
    }
}

// MARK: - CoreRoundButtonContent

@available(iOS 13, *)
private struct CoreRoundButtonContent<S> : View  where S : StringProtocol{
    
    private let title: S
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let fillParentWidth: Bool
    
    init(title: S,
         backgroundColor: Color,
         foregroundColor: Color,
         fillParentWidth: Bool) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.fillParentWidth = fillParentWidth
    }
    
    public var body: some View {
        HStack {
            if self.fillParentWidth {
                Spacer()
            }
            
            CoreButtonText(title: self.title,
                           foregroundColor: self.foregroundColor,
                           horizontalPadding: Spacing.xl)
            
            if self.fillParentWidth {
                Spacer()
            }
        }
    }
}

// MARK: - CoreButtonText

@available(iOS 13, *)
private struct CoreButtonText<S> : View where S : StringProtocol {
    
    let title: S
    let foregroundColor: Color
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    
    init(title: S,
         foregroundColor: Color,
         verticalPadding: CGFloat = Spacing.base,
         horizontalPadding: CGFloat = Spacing.base) {
        self.title = title
        self.foregroundColor = foregroundColor
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
    }
    
    public var body: some View {
        Text(self.title)
            .bodyBoldStyle()
            .foregroundColor(self.foregroundColor)
            .multilineTextAlignment(.center)
            .padding(.vertical, self.verticalPadding)
            .padding(.horizontal, self.horizontalPadding)
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13, *)
private struct Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            VStack {
                CoreButton("Hello World") {}
                
                CoreNavigationButton("Hello World", destination: Text("hi"))
                
                CoreButton("Hello World", isDestructive: true) {}
                
                CoreNavigationButton("Hello World", isDestructive: true, destination: Text("hi"))
            }
        }
        NavigationView {
            VStack {
                CoreRoundButton("Hello World") {}
                
                CoreNavigationRoundButton("Hello World",
                                          destination: Text("hi"))
                
                CoreRoundButton("Hello World", isDestructive: true) {}
                
                CoreNavigationRoundButton("Hello World",
                                          isDestructive: true,
                                          destination: Text("hi"))
                
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
}

#endif
