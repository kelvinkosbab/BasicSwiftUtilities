//
//  CoreSampleApp.swift
//
//  Created by Kelvin Kosbab on 7/24/21.
//

import SwiftUI
import CoreUI

@main
struct CoreSampleApp: App {
    
    let sessionId = UUID()
    
    var body: some Scene {
        WindowGroup {
            ContentView(sessionId: self.sessionId)
                .toastableContainer(sessionId: self.sessionId)
        }
    }
}
