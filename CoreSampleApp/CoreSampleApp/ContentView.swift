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
                NavigationLink("Blur Views") {
                    BlurViews()
                }
                NavigationLink("Core Buttons") {
                    CoreButtonViews()
                }
                NavigationLink("CoreContainerViews") {
                    CoreContainerViews()
                }
                NavigationLink("Fonts") {
                    FontViews()
                }
                NavigationLink("SF Symbols") {
                    SFSymbolTester()
                }
                NavigationLink("Toasts") {
                    ToastViews()
                }
            }
            .navigationBarTitle("Hello World", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
