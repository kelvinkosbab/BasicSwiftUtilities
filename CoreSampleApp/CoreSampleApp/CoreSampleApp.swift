//
//  CoreSampleApp.swift
//
//  Created by Kelvin Kosbab on 7/24/21.
//

import SwiftUI
import CoreUI

@main
struct CoreSampleApp: App {
    
    let toastApi = ToastApi()
    
    var body: some Scene {
        WindowGroup {
            ContentView(toastApi: self.toastApi)
                .toastableContainer(toastApi: self.toastApi)
        }
    }
}
