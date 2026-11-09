# Replacing screen-, idiom-, orientation-, and inset-based UIKit code

> **Sources.** Apple's Xcode 27 app-resizability agent skill (its UIScreen, idiom, orientation, safe-area, and scene-lifecycle tasks), as published by [Artem Novichkov](https://github.com/artemnovichkov) in [`artemnovichkov/xcode-skills`](https://github.com/artemnovichkov/xcode-skills), with TN3187 and TN3124. Rewritten and condensed for this bundle.

Use this when fixing what `size-classes-and-idiom.md` and `duo-and-poses.md` flag. Two working rules come first:

- **One deprecation per change.** When replacing `UIScreen.main`, don't also rewrite the orientation check on the next line; each kind is its own reviewable diff. Unrelated "bonus" fixes make the change hard to review and easy to get wrong.
- **Use the most local source.** A method parameter that already carries a view, view controller, or trait collection beats walking the hierarchy. A method that receives a `traitCollection` and ignores it is always wrong.

## `UIScreen.main.scale` and other screen traits

| Where the code is | Replacement |
|---|---|
| SwiftUI `View` | `@Environment(\.displayScale) private var displayScale` |
| `UIView` / `UIViewController` instance method | `traitCollection.displayScale` |
| A view or VC reachable through a parameter or property (in a view class) | `thatView.traitCollection.displayScale` |
| A non-view type (`…Manager`, `…Renderer`, `…Provider`), or a static method | add a `traitCollection:` parameter: a new overload that takes it, and the old one marked deprecated and forwarding |

Never give a SwiftUI view a `traitCollection:` parameter; the environment already propagates the value. In a non-view type, don't silently inline `someView.traitCollection` either: the parameter makes the dependency visible to callers.

## `UIScreen.main.bounds`

- In a view: `view.bounds`, or `superview.bounds` for a view sizing itself to its container. In `loadView` / `init`, before layout, use `.zero` and size the view in `layoutSubviews` / `viewDidLayoutSubviews` or with constraints.
- The window scene's size (iOS 26+): `windowScene.effectiveGeometry.coordinateSpace.bounds`. React to changes in `windowScene(_:didUpdateEffectiveGeometry:)` and check `effectiveGeometry.isInteractivelyResizing` to skip expensive work mid-drag.
- In SwiftUI: `GeometryReader` or `containerRelativeFrame`, never the screen.
- A screen-sized buffer (a full-screen snapshot, a render target) is sized from the window scene, not the screen.

## `userInterfaceIdiom`

- When it drives **layout**, replace it with the horizontal or vertical size class (`traitCollection.horizontalSizeClass`, `@Environment(\.horizontalSizeClass)`). A size-class check covers every case the idiom check did, including iPad multitasking and iPhone Duo's inner display.
- When the check is **genuinely about idiom** (a hardware capability gate, pointer or hover affordances), keep the comparison and its branches but read it from the local `traitCollection.userInterfaceIdiom`, not `UIDevice.current`, since one process can drive scenes with different idioms. An `else` branch keeps catching `.unspecified` as before.
- Reads that describe the **device**, not the environment (analytics dimensions, per-device asset names), keep `UIDevice.current`.
- A non-`View` type (a model or view model) gets the size class as a parameter per call or moves the decision into the view; don't store it, or it must be kept current on every resize.

## Orientation

`UIDevice.current.orientation`, `statusBarOrientation`, `interfaceOrientation`, `UIInterfaceOrientationIsLandscape(…)`, and a layout decision on `windowScene.effectiveGeometry.interfaceOrientation` all answer the wrong question under resizing. Replace a layout branch with a size class or the aspect of the view's bounds (`bounds.width > bounds.height`). Keep orientation only for camera or sensor work that is about the physical device.

## Safe area

- No hardcoded bar heights (20, 44, 64, 88 for status and navigation bars; 34 for the home indicator; 49, 83 for tab bars). Use `safeAreaInsets` / `safeAreaLayoutGuide` (SwiftUI handles it by default).
- No `topLayoutGuide` / `bottomLayoutGuide` (deprecated); use `view.safeAreaLayoutGuide`.
- Insets are asymmetric: never `max(left, right)` for both sides, never one edge's inset for the opposite edge, and never infer orientation or device from an inset.
- Don't store insets; read them in `safeAreaInsetsDidChange()` / layout, since a resize or fold changes them.
- Don't set `contentInsetAdjustmentBehavior = .never` to fix a layout; it puts content under the bars on every other configuration.

## Moving lifecycle code to the scene delegate

When adopting `UIScene` (see `readiness-checklist.md`):

| AppDelegate | SceneDelegate |
|---|---|
| `applicationDidBecomeActive(_:)` | `sceneDidBecomeActive(_:)` |
| `applicationWillResignActive(_:)` | `sceneWillResignActive(_:)` |
| `applicationDidEnterBackground(_:)` | `sceneDidEnterBackground(_:)` |
| `applicationWillEnterForeground(_:)` | `sceneWillEnterForeground(_:)` |

- Move the four **as a set** or not at all; observing some per app and others per scene gives mismatched counts with multiple windows. Once moved, delete the AppDelegate versions (only the scene ones are called).
- `application(_:didFinishLaunchingWithOptions:)` mixes one-time setup (analytics, database, push, SDKs: stays) with UI setup (window, root view controller, appearance, state restoration: moves to `scene(_:willConnectTo:options:)`). Ask the developer which lines move.
- Create the window with `UIWindow(windowScene:)`, remove `AppDelegate.window`, and replace `appDelegate.window` reads with `view.window` or the scene's window.
