# ``CoreUI``

SwiftUI components, modifiers, and utilities for Apple platforms.

## Overview

CoreUI provides reusable SwiftUI components and view modifiers. For UIKit utilities, see
the separate ``CoreUIKit`` module.

## Toast System

The ``ToastableContainer`` component displays transient toast notifications in your app's window.
Toasts support titles, descriptions, leading/trailing content, and configurable positioning.

```swift
@main
struct MyApp: App {

    let toastApi = ToastApi()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .toastableContainer(toastApi: self.toastApi)
        }
    }
}

// Show a toast from anywhere with access to the ToastApi:
toastApi.show(title: "Saved successfully")
```

## Color Utilities

Define colors using hex values:

```swift
Text("Hello")
    .foregroundStyle(.hex(0x5B2071))
```

See ``HexColor`` for implementation details.

## Layout Utilities

- ``Spacing`` — Standard spacing constants (`tiny`, `small`, `base`, `large`, `xl`, `xxl`).
- ``SafeAreaInsets`` — Access safe area insets via `@Environment(\.safeAreaInsets)`.
- ``CircleImage`` — Render circular images from system names or `Image` values.
- ``VerticalScrollOnDynamicTypeSize`` — Wrap content in a `ScrollView` at larger accessibility sizes.

## View Modifiers

- ``ShadowIfLightColorSchemeModifier`` — Apply shadows only in light color scheme.
- `allowAutoDismiss(_:)` — Control whether sheets can be dismissed by gesture.
- Conditional view transforms via `View.if(_:transform:)`.
