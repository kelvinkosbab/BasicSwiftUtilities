//
//  CoreRoundedView.swift
//  CoreRoundedView
//
//  Created by Kelvin Kosbab on 7/25/21.
//

import SwiftUI
import CoreUI

struct CoreRoundedViews : View {
    
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
                
                Text("Content").padding().coreContainer(backgroundStyle: .none, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(backgroundStyle: .blur, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(backgroundStyle: .secondaryFill, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(backgroundStyle: .tertiaryFill, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(backgroundStyle: .quaternaryFill, cornerStyle: .capsule)
                
                Text("Content").padding().coreContainer(applyShadow: true, backgroundStyle: .quaternaryFill, cornerStyle: .capsule)
                Text("Content").padding().coreContainer(applyShadow: false, backgroundStyle: .quaternaryFill, cornerStyle: .capsule)
            }
        }
        .navigationTitle("CoreRoundedView")
    }
}
