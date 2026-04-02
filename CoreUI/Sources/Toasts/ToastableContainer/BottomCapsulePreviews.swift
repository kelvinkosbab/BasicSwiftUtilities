//
//  BottomCapsulePreviews.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - BottomCapsulePreviews

#Preview("Bottom Capsule Previews") {

    let bottomCapsuleToastApi = ToastApi(options: ToastOptions(
        position: .bottom,
        shape: .capsule,
        style: .pop
    ))

    return NavigationView {
        List {

            Button("Bottom: Show Simple Title") {
                bottomCapsuleToastApi.show(title: "Simple Title")
            }

            Button("Bottom: Show Title & Description") {
                bottomCapsuleToastApi.show(
                    title: "Simple Title",
                    description: "Some Description"
                )
            }

            Button("Top: Show Custom Content") {
                bottomCapsuleToastApi.show(
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
                bottomCapsuleToastApi.show(
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
                bottomCapsuleToastApi.show(
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
                bottomCapsuleToastApi.show(
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
    .toastableContainer(toastApi: bottomCapsuleToastApi)
    .previewDisplayName("Bottom Capsule Toast Tests")
}

#endif
