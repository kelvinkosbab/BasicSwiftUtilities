//
//  ContentView.swift
//  CoreSampleApp
//
//  Created by Kelvin Kosbab on 7/24/21.
//

import SwiftUI

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
