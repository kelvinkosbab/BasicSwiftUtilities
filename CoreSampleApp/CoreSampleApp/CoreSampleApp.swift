//
//  CoreSampleApp.swift
//
//  Created by Kelvin Kosbab on 7/24/21.
//

import SwiftUI
import CoreUI

@main
struct CoreSampleApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .toastableContainer(target: .primary)
        }
    }
}
