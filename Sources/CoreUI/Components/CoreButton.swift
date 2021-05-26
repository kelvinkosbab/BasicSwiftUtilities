//
//  CoreButton.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreButton

@available(iOS 13, *)
public struct CoreButton : View {
    
    private let title: String
    private let isDestructive: Bool
    private let tintColor: Color
    private let destrutiveColor: Color
    private let action: () -> Void
    
    public init(_ title: String,
                isDestructive: Bool = false,
                tintColor: Color = AppColors.appTintColor,
                destrutiveColor: Color = AppColors.appDestructiveColor,
                action: @escaping () -> Void) {
        self.title = title
        self.isDestructive = isDestructive
        self.action = action
        self.tintColor = tintColor
        self.destrutiveColor = destrutiveColor
    }
    
    public var body: some View {
        Button(action: self.action) {
            CoreButtonText(title: self.title,
                           foregroundColor: self.isDestructive ? self.destrutiveColor : self.tintColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - CoreNavigationButton

@available(iOS 13, *)
public struct CoreNavigationButton<Destination> : View where Destination : View {
    
    private let title: String
    private let foregroundColor: Color
    private let destination: Destination
    
    public init(_ title: String,
                isDestructive: Bool = false,
                tintColor: Color = AppColors.appTintColor,
                destrutiveColor: Color = AppColors.appDestructiveColor,
                destination: Destination) {
        self.title = title
        self.foregroundColor = isDestructive ? destrutiveColor : tintColor
        self.destination = destination
    }
    
    public var body: some View {
        NavigationLink(destination: self.destination) {
            CoreButtonText(title: self.title,
                           foregroundColor: self.foregroundColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - CoreRoundButton

@available(iOS 13, *)
public struct CoreRoundButton : View {
    
    private let title: String
    private let backgroundColor: Color
    private let fillParentWidth: Bool
    private let action: () -> Void
    
    public init(_ title: String,
                isDestructive: Bool = false,
                tintColor: Color = AppColors.appTintColor,
                destrutiveColor: Color = AppColors.appDestructiveColor,
                fillParentWidth: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.backgroundColor = isDestructive ? destrutiveColor : tintColor
        self.fillParentWidth = fillParentWidth
        self.action = action
    }
    
    public var body: some View {
        Button(action: self.action) {
            HStack {
                if self.fillParentWidth {
                    Spacer()
                }
                
                CoreButtonText(title: self.title,
                               foregroundColor: .white,
                               horizontalPadding: Spacing.xl)
                
                if self.fillParentWidth {
                    Spacer()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(self.backgroundColor)
        .cornerRadius(Spacing.base * 2)
    }
}

// MARK: - CoreNavigationRoundButton

@available(iOS 13, *)
public struct CoreNavigationRoundButton<Destination> : View where Destination : View {
    
    private let title: String
    private let backgroundColor: Color
    private let fillParentWidth: Bool
    private let destination: Destination
    
    public init(_ title: String,
                isDestructive: Bool = false,
                tintColor: Color = AppColors.appTintColor,
                destrutiveColor: Color = AppColors.appDestructiveColor,
                fillParentWidth: Bool = false,
                destination: Destination) {
        self.title = title
        self.backgroundColor = isDestructive ? destrutiveColor : tintColor
        self.fillParentWidth = fillParentWidth
        self.destination = destination
    }
    
    public var body: some View {
        NavigationLink(destination: self.destination) {
            HStack {
                if self.fillParentWidth {
                    Spacer()
                }
                
                CoreButtonText(title: self.title,
                               foregroundColor: .white,
                               horizontalPadding: Spacing.xl)
                
                if self.fillParentWidth {
                    Spacer()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(self.backgroundColor)
        .cornerRadius(Spacing.base * 2)
    }
}

// MARK: - CoreButtonText

@available(iOS 13, *)
private struct CoreButtonText : View {
    
    let title: String
    let foregroundColor: Color
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    
    init(title: String,
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
                CoreButton("Hello World", action: {})
                CoreNavigationButton("Hello World", destination: Text("hi"))
                
                CoreButton("Hello World", isDestructive: true, action: {})
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
                
                CoreRoundButton("Hello World", fillParentWidth: true) {}
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
