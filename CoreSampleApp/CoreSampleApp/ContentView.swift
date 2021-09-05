//
//  ContentView.swift
//
//  Created by Kelvin Kosbab on 7/24/21.
//

import SwiftUI
import CoreUI

struct ContentView : View {
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("CoreButton") {
                    CoreButtonViews()
                }
                NavigationLink("CoreRoundedViews") {
                    CoreRoundedViews()
                }
                NavigationLink("Fonts") {
                    FontViews()
                }
                NavigationLink("SF Symbols") {
                    SFSymbolTester(imageType: .system("books.vertical"))
                }
                NavigationLink("Toasts") {
                    ToastViews()
                }
            }
            .navigationTitle("Hello World")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
