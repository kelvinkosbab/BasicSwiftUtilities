//
//  CoreSampleApp.swift
//
//  Copyright © Kozinga. All rights reserved.
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
