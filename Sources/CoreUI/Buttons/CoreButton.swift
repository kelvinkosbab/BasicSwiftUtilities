//
//  CoreButton.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

// MARK: - CoreButtonStyle

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public struct CoreButtonStyle : ButtonStyle {
    
    private let foregroundColor: Color?
    
    public init(
        foregroundColor: Color? = nil
    ) {
        self.foregroundColor = foregroundColor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(self.foregroundColor)
            .bodyBoldStyle()
            .multilineTextAlignment(.center)
            .padding()
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public extension ButtonStyle where Self == CoreButtonStyle {

    static var core: CoreButtonStyle {
        return CoreButtonStyle()
    }
}

// MARK: - CoreFilledButtonStyle

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public struct CoreFilledButtonStyle : ButtonStyle {
    
    private let fillParentWidth: Bool
    private let foregroundColor: Color
    private let backgroundColor: Color?
    
    public init(
        backgroundColor: Color? = nil,
        fillParentWidth: Bool = false,
        foregroundColor: Color = .white
    ) {
        self.backgroundColor = backgroundColor
        self.fillParentWidth = fillParentWidth
        self.foregroundColor = foregroundColor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(self.foregroundColor)
            .bodyBoldStyle()
            .multilineTextAlignment(.center)
            .padding()
            .padding(.horizontal)
            .modifier(MaxWidthModifier(fillParentWidth: self.fillParentWidth))
            .background(self.backgroundColor)
            .clipShape(Capsule())
    }
}

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
public extension ButtonStyle where Self == CoreFilledButtonStyle {

    static var coreFilled: CoreFilledButtonStyle {
        return CoreFilledButtonStyle()
    }
    
    static var coreFilledWide: CoreFilledButtonStyle {
        return CoreFilledButtonStyle(fillParentWidth: true)
    }
}

// MARK: - MaxWidthModifier

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
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

@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
struct CoreButton_Previews: PreviewProvider {
    
    static var previews: some View {
        if #available(iOS 14.0, tvOS 15.0, watchOS 7.0, *) {
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
        } else {
            VStack {
                self.simpleButtons
                self.filledButtons
            }
        }
    }
    
    private static var simpleButtons: some View {
        VStack(spacing: 10) {
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(.core)
            
            Button("Hello World") { print("Hello world") }
                .buttonStyle(CoreButtonStyle(foregroundColor: .yellow))
            
            NavigationLink("Hello World", destination: Text("Hi"))
                .buttonStyle(.core)
            
            if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
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
                .buttonStyle(CoreFilledButtonStyle(foregroundColor: .yellow))
            
            NavigationLink("Hello World", destination: Text("Hi"))
                .buttonStyle(.coreFilled)
            
            if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
                Button("Hello World iOS 15", role: .destructive) {
                    print("Hello world")
                }
                .buttonStyle(.coreFilled)
            }
        }
    }
}

#endif
