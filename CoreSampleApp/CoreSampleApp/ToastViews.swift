//
//  ToastViews.swift
//
//  Created by Kelvin Kosbab on 7/31/21.
//

import SwiftUI
import CoreUI

// MARK: - ToastViews

struct ToastViews : View {
    
    let toastApi: ToastApi
    let image: Image = Image(systemName: "heart.circle.fill")
    @State private var isShowingDetails = false
    
    var body: some View {
        List {
            Button("Show Title Toast") {
                self.toastApi.show(title: "Simple Title")
            }
            .padding()
            
            Button("Show Title-Image Toast") {
                self.toastApi.show(title: "Simple Title",
                                   leading: .tintedImage(self.image, .green))
            }
            .padding()
            
            Button("Show Title-description Toast") {
                self.toastApi.show(title: "Simple Title",
                                   description: "Some description")
            }
            .padding()
            
            Button("Show Title-description leading image Toast") {
                self.toastApi.show(title: "Simple Title",
                                   description: "Some description",
                                   leading: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show Title-description trailing image Toast") {
                self.toastApi.show(title: "Simple Title",
                                   description: "Some description",
                                   trailing: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show Title-description leading and trailing image Toast") {
                self.toastApi.show(title: "Simple Title",
                                   description: "Some description",
                                   leading: .tintedImage(self.image, .red),
                                   trailing: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show longer Title-description-image Toast") {
                self.toastApi.show(title: "Simple Title that is a little longer",
                                   description: "Some description",
                                   leading: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show super long Title-description-image Toast") {
                self.toastApi.show(title: "Simple Title that is a little longer Simple Title that is a little longer Simple Title that is a little longer",
                                   description: "Some description",
                                   leading: .tintedImage(self.image, .blue))
            }
            .padding()
        }
        .navigationTitle("Toasts")
        .navigationBarItems(trailing: Button("Show Modal") {
            self.isShowingDetails = true
        })
        .sheet(isPresented: self.$isShowingDetails) {
            ModalToastViews()
                .navigationTitle("ModalToasts")
        }
    }
}

struct ModalToastViews : View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let toastApi = ToastApi()
    let image: Image = Image(systemName: "heart.circle")
    
    var body: some View {
        VStack {
            Button("Dismiss") {
                self.presentationMode.wrappedValue.dismiss()
            }
            
            Button("Show Title Toast") {
                self.toastApi.show(title: "Simple Title")
            }
            .padding()
            
            Button("Show Title-Image Toast") {
                self.toastApi.show(title: "Simple Title",
                                   leading: .tintedImage(self.image, .green))
            }
            .padding()
            
            Button("Show Title-description Toast") {
                self.toastApi.show(title: "Simple Title",
                                   description: "Some description")
            }
            .padding()
            
            Button("Show Title-description leading image Toast") {
                self.toastApi.show(title: "Simple Title",
                                   description: "Some description",
                                   leading: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show Title-description trailing image Toast") {
                self.toastApi.show(title: "Simple Title",
                                   description: "Some description",
                                   trailing: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show Title-description leading and trailing image Toast") {
                self.toastApi.show(title: "Simple Title",
                                   description: "Some description",
                                   leading: .tintedImage(self.image, .red),
                                   trailing: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show longer Title-description-image Toast") {
                self.toastApi.show(title: "Simple Title that is a little longer",
                                   description: "Some description",
                                   leading: .tintedImage(self.image, .blue))
            }
            .padding()
            
            Button("Show super long Title-description-image Toast") {
                self.toastApi.show(title: "Simple Title that is a little longer Simple Title that is a little longer Simple Title that is a little longer",
                                   description: "Some description",
                                   leading: .tintedImage(self.image, .blue))
            }
            .padding()
        }
        .toastableContainer(toastApi: self.toastApi)
    }
}
