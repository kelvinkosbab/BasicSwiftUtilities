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
                               image: self.image,
                               imageTintColor: .green)
                }
                .padding()
                
                Button("Show Title-description Toast") {
                    Toast.show(title: "Simple Title",
                               description: "Some description")
                }
                .padding()
                
                Button("Show Title-description-image Toast") {
                    Toast.show(title: "Simple Title",
                               description: "Some description",
                               image: self.image,
                               imageTintColor: .blue)
                }
                .padding()
                
                Button("Show longer Title-description-image Toast") {
                    Toast.show(title: "Simple Title that is a little longer",
                               description: "Some description",
                               image: self.image,
                               imageTintColor: .blue)
                }
                .padding()
                
                Button("Show super long Title-description-image Toast") {
                    Toast.show(title: "Simple Title that is a little longer Simple Title that is a little longer Simple Title that is a little longer",
                               description: "Some description, Some description, Some description, Some description, Some description, Some description, Some descriptionSome description",
                               image: self.image,
                               imageTintColor: .blue)
                }
                .padding()
            }
        }
        .navigationTitle("Toasts")
    }
}
