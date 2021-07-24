//
//  ContentView.swift
//  CoreSampleApp
//
//  Created by Kelvin Kosbab on 7/24/21.
//

import SwiftUI
import CoreUI

struct ContentView : View {
    
    var body: some View {
        NavigationView {
            NavigationLink("CoreButton") {
                CoreButtonViews()
                    .padding()
            }
        }
    }
}

struct CoreButtonViews : View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                self.simpleButtons
                self.roundedButtons
                self.wideRoundButtons
            }
        }
        .navigationTitle("CoreButton")
    }
    
    private var simpleButtons: some View {
        VStack(spacing: 10) {
            
            CoreButton("Hello World") {}
            
            CoreNavigationButton("Hello World", destination: Text("hi"))
            
            CoreButton("Hello World", isDestructive: true) {}
            
            CoreNavigationButton("Hello World", isDestructive: true, destination: Text("hi"))
        }
    }
    
    private var roundedButtons: some View {
        VStack(spacing: 10) {
            
            CoreRoundButton("Hello World") {}
            
            CoreNavigationRoundButton("Hello World",
                                      destination: Text("hi"))
            
            CoreRoundButton("Hello World", isDestructive: true) {}
            
            CoreNavigationRoundButton("Hello World",
                                      isDestructive: true,
                                      destination: Text("hi"))
        }
    }
    
    private var wideRoundButtons: some View {
        VStack(spacing: 10) {
            
            CoreRoundButton("Hello World",
                            fillParentWidth: true) {}
            
            CoreNavigationRoundButton("Hello World",
                                      fillParentWidth: true,
                                      destination: Text("hi"))
            
            CoreRoundButton("Hello World",
                            isDestructive: true,
                            fillParentWidth: true) {}
            
            CoreNavigationRoundButton("Hello World",
                                      isDestructive: true,
                                      fillParentWidth: true,
                                      destination: Text("hi"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        CoreButtonViews()
    }
}
