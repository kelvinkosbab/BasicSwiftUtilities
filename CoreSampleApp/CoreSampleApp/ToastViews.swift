//
//  ToastViews.swift
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
                Button("Show Title Toast") {
                    Toast.show(title: "Simple Title")
                }
                .padding()
                
                Button("Show Title-Image Toast") {
                    Toast.show(title: "Simple Title",
                               leadingImage: (image: self.image, tintColor: .green))
                }
                .padding()
                
                Button("Show Title-description Toast") {
                    Toast.show(title: "Simple Title",
                               description: "Some description")
                }
                .padding()
                
                Button("Show Title-description leading image Toast") {
                    Toast.show(title: "Simple Title",
                               description: "Some description",
                               leadingImage: (image: self.image, tintColor: .blue))
                }
                .padding()
                
                Button("Show Title-description trailing image Toast") {
                    Toast.show(title: "Simple Title",
                               description: "Some description",
                               trailingImage: (image: self.image, tintColor: .blue))
                }
                .padding()
                
                Button("Show Title-description leading and trailing image Toast") {
                    Toast.show(title: "Simple Title",
                               description: "Some description",
                               leadingImage: (image: self.image, tintColor: .red),
                               trailingImage: (image: self.image, tintColor: .blue))
                }
                .padding()
                
                Button("Show longer Title-description-image Toast") {
                    Toast.show(title: "Simple Title that is a little longer",
                               description: "Some description",
                               leadingImage: (image: self.image, tintColor: .blue))
                }
                .padding()
                
                Button("Show super long Title-description-image Toast") {
                    Toast.show(title: "Simple Title that is a little longer Simple Title that is a little longer Simple Title that is a little longer",
                               description: "Some description",
                               leadingImage: (image: self.image, tintColor: .blue))
                }
                .padding()
            }
        }
        .navigationTitle("Toasts")
    }
}
