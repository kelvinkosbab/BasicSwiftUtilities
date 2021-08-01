//
//  Toasts.swift
//  Toasts
//
//  Created by Kelvin Kosbab on 7/31/21.
//

import SwiftUI
import CoreUI

// MARK: - ToastViews

struct ToastViews : View {
    
    let image: Image = Image(systemName: "heart.circle.fill")
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ToastView(.constant(ToastContent(title: "One")))
                ToastView(.constant(ToastContent(title: "Two",
                                                 image: self.image,
                                                 tintColor: .green)))
                ToastView(.constant(ToastContent(title: "Two",
                                                 description: "Hello")))
                ToastView(.constant(ToastContent(title: "Two",
                                                 description: "Hello",
                                                 image: self.image,
                                                 tintColor: .blue)))
            }
        }
        .navigationTitle("Toasts")
    }
}
