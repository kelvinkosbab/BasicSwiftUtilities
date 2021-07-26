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
                CoreRoundedView(.corenerRadius(20)) {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Left Top")
                        Text("Left Bottom")
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Trailing")
                    }
                }
                CoreRoundedView(.capsule) {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Left Top")
                        Text("Left Bottom")
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Trailing")
                    }
                }
            }
        }
        .navigationTitle("CoreRoundedView")
    }
}
