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
                }
                CoreRoundedView(.capsule) {
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
                }
            }
        }
        .navigationTitle("CoreRoundedView")
    }
}
