//
//  BottomRoundedRectanglePreviews.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(watchOS)

import SwiftUI

// MARK: - BottomRoundedRectanglePreviews

#Preview("Bottom RoundedRectangle Previews") {

    let bottomRoundedRectangleToastApi = ToastApi(options: ToastOptions(
        position: .bottom,
        shape: .roundedRectangle
    ))

    return NavigationView {
        List {

            Button("Bottom: Show Simple Title") {
                bottomRoundedRectangleToastApi.show(title: "Simple Title")
            }

            Button("Bottom: Show Title & Description") {
                bottomRoundedRectangleToastApi.show(
                    title: "Simple Title",
                    description: "Some Description"
                )
            }

            Button("Top: Show Custom Content") {
                bottomRoundedRectangleToastApi.show(
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
                bottomRoundedRectangleToastApi.show(
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
                bottomRoundedRectangleToastApi.show(
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
                bottomRoundedRectangleToastApi.show(
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
    .toastableContainer(toastApi: bottomRoundedRectangleToastApi)
    .previewDisplayName("Bottom RoundedRectangle Toast Tests")
}

#endif
