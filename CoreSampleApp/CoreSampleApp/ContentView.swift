//
//  ContentView.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI
import CoreUI

struct ContentView : View {
    
    let toastApi: ToastApi
    
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
                    ToastViews(toastApi: self.toastApi)
                }
            }
            .navigationBarTitle("Hello World", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(toastApi: ToastApi())
    }
}
