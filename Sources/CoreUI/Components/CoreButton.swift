//
//  CoreButton.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - ButtonRole

public enum ButtonRole {
    case destructive
}

// MARK: - CoreButton

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CoreButton {
    
    static func getColor(for role: ButtonRole?) -> Color {
        return role == .destructive ? AppColors.appDestructiveColor : AppColors.appTintColor
    }
}

// MARK: - CoreButtonStyle

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CoreButtonStyle : ButtonStyle {
    
    private let foregroundColor: Color?
    
    public init(foregroundColor: Color? = nil) {
        self.foregroundColor = foregroundColor
    }
    
    public init(role: ButtonRole) {
        self.foregroundColor = CoreButton.getColor(for: role)
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let role: ButtonRole? = {
            if #available(iOSApplicationExtension 15.0, *) {
                return configuration.role == .destructive ? .destructive : nil
            } else {
                return nil
            }
        }()
        let foregroundColor = self.foregroundColor ?? CoreButton.getColor(for: role)
        configuration.label
            .foregroundColor(foregroundColor)
            .bodyBoldStyle()
            .multilineTextAlignment(.center)
            .padding()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ButtonStyle where Self == CoreButtonStyle {

    static var core: CoreButtonStyle {
        return CoreButtonStyle()
    }
    
    static var coreDestructive: CoreButtonStyle {
        return CoreButtonStyle(role: .destructive)
    }
}

// MARK: - CoreFilledButtonStyle

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CoreFilledButtonStyle : ButtonStyle {
    
    private let fillParentWidth: Bool
    private let foregroundColor: Color
    private let backgroundColor: Color?
    
    public init(backgroundColor: Color? = nil,
                fillParentWidth: Bool = false,
                foregroundColor: Color = .white) {
        self.backgroundColor = backgroundColor
        self.fillParentWidth = fillParentWidth
        self.foregroundColor = foregroundColor
    }
    
    public init(fillParentWidth: Bool = false,
                foregroundColor: Color = .white,
                role: ButtonRole?) {
        self.backgroundColor = CoreButton.getColor(for: role)
        self.fillParentWidth = fillParentWidth
        self.foregroundColor = foregroundColor
        
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let role: ButtonRole? = {
            if #available(iOSApplicationExtension 15.0, *) {
                return configuration.role == .destructive ? .destructive : nil
            } else {
                return nil
            }
        }()
        let backgroundColor = self.backgroundColor ?? CoreButton.getColor(for: role)
        configuration.label
            .foregroundColor(self.foregroundColor)
            .bodyBoldStyle()
            .multilineTextAlignment(.center)
            .padding()
            .padding(.horizontal, Spacing.base)
            .modifier(MaxWidthModifier(fillParentWidth: self.fillParentWidth))
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ButtonStyle where Self == CoreFilledButtonStyle {

    static var coreFilled: CoreFilledButtonStyle {
        return CoreFilledButtonStyle()
    }
    
    static var coreFilledDestructive: CoreFilledButtonStyle {
        return CoreFilledButtonStyle(role: .destructive)
    }
    
    static var coreFilledWide: CoreFilledButtonStyle {
        return CoreFilledButtonStyle(fillParentWidth: true)
    }
    
    static var coreFilledDestructiveWide: CoreFilledButtonStyle {
        return CoreFilledButtonStyle(fillParentWidth: true, role: .destructive)
    }
}

// MARK: - MaxWidthModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CoreButton_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            VStack {
                self.simpleButtons
            }
        }
        
        NavigationView {
            VStack {
                self.filledButtons
            }
        }
    }
    
    private static var simpleButtons: some View {
        VStack(spacing: 10) {
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(.core)
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(.coreDestructive)
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(CoreButtonStyle(foregroundColor: .yellow))
            
            NavigationLink("Hello World", destination: Text("Hi"))
                .buttonStyle(.core)
            
            if #available(iOS 15.0, *) {
                Button("Hello World iOS 15", role: .destructive) { print("Hello world") }
                    .buttonStyle(.core)
            }
        }
    }
    
    private static var filledButtons: some View {
        VStack(spacing: 10) {
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(.coreFilled)
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(.coreFilledWide)
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(.coreFilledDestructive)
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(.coreFilledDestructiveWide)
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(.coreDestructive)
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(CoreFilledButtonStyle(foregroundColor: .yellow))
            
            NavigationLink("Hello World", destination: Text("Hi")) 
                .buttonStyle(.coreFilled)
            
            if #available(iOS 15.0, *) {
                Button("Hello World iOS 15", role: .destructive) { print("Hello world") }
                    .buttonStyle(.coreFilled)
            }
        }
    }
}

#endif
