//
//  CoreContainerViews.swift
//
//  Created by Kelvin Kosbab on 7/25/21.
//

import SwiftUI
import CoreUI

struct CoreContainerViews : View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Left Top")
                        Text("Left Bottom")
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Trailing")
                    }
                }
                .padding()
                .coreContainer(backgroundStyle: .secondaryFill, cornerStyle: .corenerRadius(25))
                
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Left Top")
                        Text("Left Bottom")
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Trailing")
                    }
                }
                .padding()
                .coreContainer(backgroundStyle: .secondaryFill, cornerStyle: .capsule)
                
                Text("Content").padding().coreContainer(backgroundStyle: .blur(.prominent), cornerStyle: .capsule)
                Text("Content").padding().coreContainer(backgroundStyle: .secondaryFill, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(backgroundStyle: .tertiaryFill, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(backgroundStyle: .quaternaryFill, cornerStyle: .capsule)
                
                Text("Content").padding().coreContainer(shadowStyle: .shadow, backgroundStyle: .quaternaryFill, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(shadowStyle: .none, backgroundStyle: .quaternaryFill, cornerStyle: .capsule)
            }
        }
        .navigationTitle("CoreContainerViews")
    }
}
