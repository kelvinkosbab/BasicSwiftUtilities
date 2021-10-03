//
//  ToastViews.swift
//
//  Created by Kelvin Kosbab on 7/31/21.
//

import SwiftUI
import CoreUI

// MARK: - ToastViews

struct ToastViews : View {
    
    let sessionId: UUID
    
    let image: Image = Image(systemName: "heart.circle.fill")
    
    var body: some View {
        List {
            Button("Show Title Toast") {
                Toast.show(in: self.sessionId, title: "Simple Title")
            }
            .padding()
            
            Button("Show Title-Image Toast") {
                Toast.show(in: self.sessionId,
                           title: "Simple Title",
                           leading: .tintedImage(self.image, .green))
            }
            .padding()
            
            Button("Show Title-description Toast") {
                Toast.show(in: self.sessionId,
                           title: "Simple Title",
                           description: "Some description")
            }
            .padding()
            
            Button("Show Title-description leading image Toast") {
                Toast.show(in: self.sessionId,
                           title: "Simple Title",
                           description: "Some description",
                           leading: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show Title-description trailing image Toast") {
                Toast.show(in: self.sessionId,
                           title: "Simple Title",
                           description: "Some description",
                           trailing: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show Title-description leading and trailing image Toast") {
                Toast.show(in: self.sessionId,
                           title: "Simple Title",
                           description: "Some description",
                           leading: .tintedImage(self.image, .red),
                           trailing: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show longer Title-description-image Toast") {
                Toast.show(in: self.sessionId,
                           title: "Simple Title that is a little longer",
                           description: "Some description",
                           leading: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show super long Title-description-image Toast") {
                Toast.show(in: self.sessionId,
                           title: "Simple Title that is a little longer Simple Title that is a little longer Simple Title that is a little longer",
                           description: "Some description",
                           leading: .tintedImage(self.image, .blue))
            }
            .padding()
        }
        .navigationTitle("Toasts")
    }
}
