//
//  TopCapsulePreviews.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - TopCapsulePreviews

#Preview("Top Capsule Previews") {
    
    let topCapsuleToastApi = ToastApi(options: ToastOptions(
        position: .top,
        shape: .capsule
    ))
    
    return NavigationView {
        List {
            
            Button("Top: Show Simple Title") {
                topCapsuleToastApi.show(title: "Simple Title")
            }
            
            Button("Top: Show Title & Description") {
                topCapsuleToastApi.show(
                    title: "Simple Title",
                    description: "Some Description"
                )
            }
            
            Button("Top: Show Custom Content") {
                topCapsuleToastApi.show(
                    content: {
                        HStack {
                            Circle()
                                .foregroundColor(.cyan)
                                .padding()
                            Rectangle()
                                .foregroundColor(.green)
                                .padding()
                        }
                    }
                )
            }
            
            Button("Top: Show Custom Content & Leading") {
                topCapsuleToastApi.show(
                    content: {
                        Text("Hello there")
                            .font(.body)
                            .foregroundColor(.primary)
                    },
                    leading: {
                        Image(systemName: "heart.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    }
                )
            }
            
            Button("Top: Show Custom Content & Trailing") {
                topCapsuleToastApi.show(
                    content: {
                        Text("Hello there")
                            .font(.body)
                            .foregroundColor(.primary)
                    },
                    trailing: {
                        Image(systemName: "person.3.sequence.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(
                                .linearGradient(colors: [.red, .clear], startPoint: .top, endPoint: .bottomTrailing),
                                .linearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottomTrailing),
                                .linearGradient(colors: [.blue, .clear], startPoint: .top, endPoint: .bottomTrailing)
                            )
                    }
                )
            }
            
            Button("Top: Show Custom Content & Leading & Trailing") {
                topCapsuleToastApi.show(
                    content: {
                        VStack(spacing: Spacing.tiny) {
                            Text("Hello there")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                            Text("Hello there")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                        }
                    },
                    leading: {
                        Image(systemName: "heart.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                    },
                    trailing: {
                        Image(systemName: "person.3.sequence.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.blue, .green, .red)
                    }
                )
            }
        }
    }
    .toastableContainer(toastApi: topCapsuleToastApi)
    .previewDisplayName("Top Capsule Toast Tests")
}

#endif
