# Multitasking, multiple windows, and scene accessories

Resizing isn't only folding. On iPhone Duo every app takes part in Split View and a stacked video-plus-app layout, Duo is the first iPhone that runs several windows of one app, and iPhone Mirroring on the Mac resizes apps too. On iPad all of this is old news; on iPhone it is new, so code written for "one window, one size" is now reachable.

> **Grounding.** Apple Tech Talks "Prepare your app for iPhone Duo" and "Leverage multiple displays and scenes on iPhone Duo", and the "Preparing your app for iPhone Duo" documentation. `sceneAccessory` is iOS 27.0; `CameraCaptureAccessory` is iOS 27.1.

## Split View and stacked layouts

- **No dedicated API.** The app gets a smaller scene, and size classes plus scene geometry are the whole contract. A Split View slot can drop to compact width while the device is still a "regular/regular" Duo, so flag any layout keyed to the device state rather than the scene.
- **Live resizes.** Dragging the divider resizes the scene continuously. State tied to a width threshold (a column count, an expanded sidebar) must survive crossing it repeatedly; look for `onChange(of: horizontalSizeClass)` handlers that reset selection or scroll position.
- **Vertical bars can land on either side of the slot**, so safe areas are asymmetric even on the inner display. Same finding as the symmetric-inset math in `duo-and-poses.md`.
- **Test it:** in Device Hub drag the app by its home indicator to one side of the inner display, then to the other side. Name both in the review.

## Multiple windows

- **`UIApplicationSupportsMultipleScenes`** decides whether a second window can exist. Check it matches intent; an iPad app that opted in now gets multiple windows on iPhone Duo too.
- **Availability is dynamic on Duo.** New windows can be created on the inner display but **not on the outer display**, and the capability flips as the device folds. Findings:
  - an "Open in New Window" menu item or button that is always shown. UIKit: use `UIWindowScene.ActivationAction`, which hides itself when activation isn't available. SwiftUI: gate on `@Environment(\.supportsMultipleWindows)`.
  - `UIApplication.shared.activateSceneSession(for:errorHandler:)` with a `nil` or empty `errorHandler`. The request can fail; the user needs feedback or a fallback (push the content in the current window).
  - drag-to-new-window (`NSItemProvider` + `UIWindowScene.ActivationConfiguration`) with no in-window fallback.
- **Closing the device keeps the most recently used window active and backgrounds the rest.** Each scene must save its own state when it backgrounds. Flag state saved only from `applicationWillTerminate` or the app delegate.
- **Per-scene state, not global state.** A singleton "current document", "selected tab", or navigation path breaks when two windows show different content. Prefer `@SceneStorage`, a model owned by the scene's root view, or `NSUserActivity` restoration per `UISceneSession`.
- **Scene geometry, not window count.** Code that looks at `UIApplication.shared.connectedScenes.first` or `windows.first` to find "the" window is wrong with more than one. Use the view's own `window?.windowScene`.

## Scene accessories

`.sceneAccessory { … }` attaches supplementary content to the scene of the view it's on, shown on another display:

| Accessory | Shows on | Available when |
|---|---|---|
| `ExternalNonInteractiveAccessory` (iOS 27) | an external display | the system enables it |
| `CameraCaptureAccessory` (iOS 27.1) | Duo's outer display | the app is full screen on the inner display **and** a camera capture session is active |

```swift
CameraView(model: model)
    .sceneAccessory {
        CameraCaptureAccessory(isEnabled: $model.isTeleprompterOn) {
            TeleprompterView(model: model)
        }
        .onAvailabilityChange { model.isTeleprompterAvailable = $0 }
    }
    .toolbar {
        TeleprompterToggle(isOn: $model.isTeleprompterOn)
            .disabled(!model.isTeleprompterAvailable)
    }
```

Findings:

- **No `onAvailabilityChange`** while a control toggles the accessory. The system can turn availability off at any time (the device closes, capture stops, the user splits the screen); the toggle must follow it.
- **The accessory attached at the app root** instead of the view that owns the content, so it outlives the camera screen.
- **App content planned for both Duo displays at once** outside a capture accessory. The outer display shows nothing from the app while the device is open.
- In the Xcode 27.1 simulator, a `CameraCaptureAccessory` showed without an active capture session. Xcode 27.2 fixed that, so retest availability logic there rather than trusting a 27.1 run.

## Audit sequence

1. `UIApplicationSupportsMultipleScenes` and the scene manifest: does multi-window match intent?
2. Grep `activateSceneSession`, `requestSceneSessionActivation`, `openWindow`, `ActivationAction`: is availability handled and is there an error path?
3. Grep `connectedScenes.first`, `windows.first`, `keyWindow`, and app-wide singletons that hold per-window state.
4. Where does each scene save state when it backgrounds?
5. Grep `sceneAccessory`: availability observed, attached to the right view?
6. Name the multitasking cases exercised: Split View on each side, the stacked video layout, a second window, iPhone Mirroring, and fold with two windows open.
