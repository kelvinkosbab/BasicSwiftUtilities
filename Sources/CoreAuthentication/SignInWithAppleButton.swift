//
//  SignInWithAppleButton.swift
//
//  Copyright © 2020 Kozinga. All rights reserved.
//

import SwiftUI
import AuthenticationServices

// MARK: - SignInWithAppleButton

@available(iOS 13, *)
public struct SignInWithAppleButton: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    public init() {}
    
    public var body: some View {
        SignInWithAppleButtonInternal(colorScheme: self.colorScheme)
    }
}

@available(iOS 13, *)
private struct SignInWithAppleButtonInternal: UIViewRepresentable {
    
    let colorScheme: ColorScheme
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button: ASAuthorizationAppleIDButton
        switch self.colorScheme {
        case .light:
            button = ASAuthorizationAppleIDButton(type: .default, style: .black)
        case .dark:
            button = ASAuthorizationAppleIDButton(type: .default, style: .white)
        @unknown default:
            button = ASAuthorizationAppleIDButton(type: .default, style: .black)
        }
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}

#if DEBUG

@available(iOS 13, *)
struct SignInWithAppleButton_Previews: PreviewProvider {
    
    static var previews: some View {
        SignInWithAppleButton()
            .padding(.horizontal, 20)
    }
}

#endif
