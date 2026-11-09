---
description: Adaptive layout for resizable iOS apps and iPhone Duo — size classes over idiom, the iOS 27 resizability default, the UIScene mandate, multitasking and multiple windows, ArrangementView and hinge APIs, reserved regions, vertical bars, zero UIKit layout margins, fold continuity, and Device Hub testing
globs: "**/*.{swift,h,m,mm}"
paths:
  - "**/*.{swift,h,m,mm}"
must:
  - "Adopt the UIScene lifecycle; apps without it won't launch on the latest SDKs."
  - "Branch on size classes, never on idiom, device, or interface orientation."
  - "Never read `UIScreen.main`; get the screen from the window scene."
  - "Use arrangements for two-pane layout; the hinge is optional polish, and `context.hinge` can be nil."
---

# Apple Adaptive Layout (Resizable Apps & iPhone Duo)

On iOS 27 every iPhone app is resizable, and iPhone Duo adds a second display, a fold, and multiple windows. This is the checklist; the full rule with code, testing, and the vertical-bar and scene-accessory APIs is in [`adaptive-layout-conventions.md`](../skills/swift-adaptive-layout-pro/references/adaptive-layout-conventions.md), and `swift-adaptive-layout-pro` runs the audit.

## Launch first

- **Adopt the `UIScene` lifecycle.** An app on the legacy app lifecycle won't launch against the latest SDKs.
- **`UIRequiresFullScreen` is no longer an opt-out.** On iOS 27 it selects discrete resizing; plan for every size.
- **Xcode 27.2:** `UIView` subviews get zero default layout margins on iOS 27.1+, and Mac Catalyst can't compile the 27.1 APIs, so wrap Duo-only code in `#if !targetEnvironment(macCatalyst)`.

## Branch on space, never on device

- **Size classes drive layout** (`horizontalSizeClass` / `verticalSizeClass`). Never the idiom, never interface orientation. Duo's inner display is regular/regular.
- **Never read `UIScreen.main`.** Use `window?.windowScene?.screen` and `traitCollection.displayScale`.
- **Let containers adapt:** `NavigationSplitView`, `TabView` with `.defaultTabBarPlacement(.sidebar)`, `ViewThatFits`. Standalone `UIToolbar` / `UINavigationBar` don't adapt; host them in a container.
- **No hardcoded sizes, aspect ratios, corner radii, or symmetric safe-area math.** Inset by `safeAreaInsets`; use `ConcentricRectangle()` / `UICornerConfiguration`.

## Fold, hinge, and reserved regions (iOS 27.1)

- **Two panes around the fold use an arrangement** (`ArrangementView`, `UIArrangementViewController` as the navigation root). Arrangements are layout, not navigation: no navigation containers inside, no arrangement inside a `List` or scroll view.
- **The hinge is optional polish.** `context.hinge` is nil on every non-folding device and on Duo's outer display; never force-unwrap it and never drive structure from the angle.
- **Ask for reserved regions** (`.division`, `.occlusion`) instead of computing the fold, re-read them on layout, and never put a control inside one.
- **Vertical bars:** every bar item has a title and an icon, Back/Close first, overflow planned with `visibilityPriority`; opt out only for close-only sheets and bottom-heavy single screens.

## Windows and continuity

- **Every size is reachable at any moment**, including a compact Split View slot with asymmetric safe areas.
- **Multiple windows on iPhone:** set `UIApplicationSupportsMultipleScenes` deliberately, keep per-window state per scene, save scene state on background, and use `UIWindowScene.ActivationAction` (it hides itself on the outer display) with an `errorHandler`.
- **Folding and unfolding keep** navigation depth, selection, text entry and first responder, scroll position, playback, in-flight work, and the session. A pushed detail becomes the detail pane on unfold.
- **Update, don't rebuild:** hoist SwiftUI `@State` above layout branches; update UIKit hierarchies in trait-change callbacks; drop values cached from the old geometry.

## Testing

- In Device Hub, go several screens deep, open a sheet, start typing, then fold and unfold; repeat in Split View on each side, a second window, and free resize.
- VoiceOver, cameras, reachability, and haptics on Duo need a physical device.
