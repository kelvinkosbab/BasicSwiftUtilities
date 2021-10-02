//
//  CoreButtonViews.swift
//  CoreButtonViews
//
//  Created by Kelvin Kosbab on 7/25/21.
//

import SwiftUI
import CoreUI

struct CoreButtonViews : View {
    
    var body: some View {
        List {
            VStack(spacing: 10) {
                self.simpleButtons
                self.filledButtons
            }
        }
        .navigationTitle("CoreButton")
    }
    
    private var simpleButtons: some View {
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
    
    private var filledButtons: some View {
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

struct CoreButtonViews_Previews: PreviewProvider {
    static var previews: some View {
        CoreButtonViews()
    }
}
