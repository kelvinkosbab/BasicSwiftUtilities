# Apple Adaptive Layout (full reference)

The long form of the `apple-adaptive-layout.md` rule, loaded only when this skill needs the detail. The rule keeps a short checklist; everything below is the complete guidance.

**Building against the iOS 27 SDK opts your app into resizability.** Adaptive layout is no longer an iPad refinement — it's the platform default on iPhone too, and iPhone Duo (Apple's book-style foldable: 5.4″ outer display, 7.6″ inner) makes a fixed-size assumption visible on a phone. Two hard consequences before any styling question:

- **The UIScene lifecycle is mandatory.** An app still using only the legacy app lifecycle **will not launch** when built with the latest SDKs. Migrate to `UIScene` first; nothing below matters until it launches.
- **`UIRequiresFullScreen` no longer opts you out.** On iPhone under iOS 27 it's honored as *discrete* resizing — the system transitions the scene to a new configuration matching each size, honoring your supported orientations. It's a rendering-quality escape hatch for games, not a way to stay fixed-size.

> **Toolchain.** The iPhone Duo APIs below (`ArrangementView`, `onHingeChange` / `UIHingeInteraction`, reserved regions, vertical bars, `CameraCaptureAccessory`) are **iOS 27.1** APIs. Xcode 27.1 introduced them with the iPhone Duo simulator; **Xcode 27.2 is the mainline toolchain that includes them** (iOS 27.2 SDK, Swift 6.4, Apple silicon, macOS Tahoe 26.6+). Pin Xcode 27.2 rather than keeping a separate 27.1 install. Gate the APIs with `if #available(iOS 27.1, *)` while the deployment target is lower, and verify spellings against the SDK you build with.

## Building With Xcode 27.2 — Two Changes Existing Code Feels

- **`UIView` default layout margins are zero on iOS 27.1+.** A view controller's root view still gets `systemMinimumLayoutMargins` (which vary by presentation context), but plain subviews no longer inherit margins. Subviews that pin to `layoutMarginsGuide` and expect inset content must set `preservesSuperviewLayoutMargins = true`, or pin to `safeAreaLayoutGuide` / explicit constants instead. Re-check margin-based UIKit layouts after the SDK bump.
- **Mac Catalyst doesn't compile the iOS 27.1 APIs yet** (Xcode 27.2 known issue). Wrap Duo-only code in `#if !targetEnvironment(macCatalyst)` (`#if !TARGET_OS_MACCATALYST` in Objective-C) on top of the availability check, and don't set a Catalyst deployment target of 27.1 or 27.2. Remove the guards once Apple ships the fix.

## Branch on Space, Never on Device

- **Size classes are the primary tool.** SwiftUI `@Environment(\.horizontalSizeClass)` / `\.verticalSizeClass`; UIKit `traitCollection.horizontalSizeClass` / `.verticalSizeClass`.
- **The user-interface idiom is no longer meaningful for layout.** `UIDevice.current.userInterfaceIdiom == .pad` tells you nothing about available space — Duo's inner display reports **regular width *and* regular height** (so sidebars are appropriate) while still being an iPhone. Apps are expected to use the space they're given regardless of idiom.
- **Never branch on interface orientation.** The inner display does not honor `supportedInterfaceOrientations` for resizable apps. Orientation is an output of window shape, not an input to layout.
- **Never read `UIScreen.main`** — ambiguous on a two-display device and deprecated. Get the screen from the scene: `window?.windowScene?.screen`; for scale use `traitCollection.displayScale`.
- Prefer **local view/scene geometry** (`GeometryReader`, `containerRelativeFrame()`, the view's own `bounds`) over anything global.

```swift
// ❌ Idiom + orientation — both wrong on Duo, iPad multitasking, and Mac Catalyst
if UIDevice.current.userInterfaceIdiom == .pad { showSidebar() }

// ✅ Branch on the space you actually have
@Environment(\.horizontalSizeClass) private var horizontalSizeClass
var showsSidebar: Bool { horizontalSizeClass == .regular }
```

## Let the System Containers Adapt

Reach for these before hand-rolling conditionals — they already handle folded/unfolded, split view, and free resize: `NavigationSplitView` / `UISplitViewController`, `TabView` / `UITabBarController`, sheets, popovers, context menus, alerts.

- **`ViewThatFits`** is the cheap win for one-off orientation flips — it picks the first child that fits instead of you branching:

  ```swift
  ViewThatFits(in: .horizontal) {
      HStack { Detail(); Sidebar() }   // preferred when there's room
      VStack { Detail(); Sidebar() }   // fallback when there isn't
  }
  ```

- **Sidebar placement on a large inner display:** `TabView { … }.defaultTabBarPlacement(.sidebar)` (SwiftUI) / `tabBarController.sidebar.preferredPlacement = .sidebar` (UIKit).
- **Standalone UIKit bars don't adapt.** A bare `UIToolbar` / `UINavigationBar` outside a navigation or tab container won't get the system's vertical-bar and edge-to-edge treatment — host it in the container instead.

## Arrangements — Two Views Around the Fold (iOS 27.1)

When two views should coexist across the hinge, use `ArrangementView` rather than a hand-built conditional:

```swift
ArrangementView {
    VideoPlayer(player: player)          // primary — top half in tabletop pose
} secondary: {
    PlaybackControls(player: player)     // secondary — bottom half, off the fold
}
.arrangementViewStyle(.split)            // .split keeps both visible; .overlay stacks
```

- **`.split`** (the default) divides the bounds and keeps both regions unobscured. **`.overlay`** floats the secondary over the primary — a foreground/background relationship.
- **UIKit:** `UIArrangementViewController` as the **root view controller of your `UINavigationController`**, configured with primary and secondary view controllers.
- **Arrangements are layout, not navigation.** Don't nest navigation containers *inside* one, and don't embed an arrangement in a `List` or scroll view.
- **Don't re-derive the split from the hinge angle.** The arrangement already adapts around available space *and* the fold — that's the whole point.
- Prefer `NavigationSplitView` when the relationship is list→detail with selection and back behavior; `ArrangementView` is for two co-resident views.

## The Hinge — Enhancement Only

```swift
.onHingeChange { _, context in
    // `context.hinge` is OPTIONAL — most displays have no hinge at all.
    if let hinge = context.hinge, hinge.status == .partiallyOpen {
        foldEffect = min(max(hinge.angle.degrees / 180, 0), 1)
    } else {
        foldEffect = 0
    }
}
```

- **UIKit:** add a `UIHingeInteraction(updateHandler:)` to the view; each `UIHingeInteraction.Update` carries an optional `hinge` (`UIHinge`, with `angle` and `status`).
- **`context.hinge` is optional** — every non-folding device, and the Duo's own outer display, has none. Code that force-unwraps it is broken on the entire rest of the lineup.
- **Never drive layout from the raw hinge angle.** Use size classes and arrangements for structure; spend the angle on *optional* polish — Apple's own "unfold effect" animates the outer display into feeling like a window onto the inner one.
- `hinge.status` gives the coarse state; `hinge.angle.degrees` the continuous value. Treat status as a layout-adjacent signal and the angle purely as animation input — layouts that snap per degree read as jitter.
- **Spend posture code where it pays**: camera, video, and media playback benefit from the tabletop stand. A settings screen needs no hinge code; posture-reactive layout everywhere is over-engineering.

## Reserved Regions — Ask, Don't Infer (iOS 27.1)

The fold and system UI claim space. Query it instead of computing it:

```swift
GeometryReader { proxy in
    let divisions  = proxy.reservedRegions(kind: .division)   // the fold splitting content
    let occlusions = proxy.reservedRegions(kind: .occlusion)  // hardware/system UI covering it
    // Each region exposes .frame, .margins, and .isActive.
}
```

- **UIKit:** `view.reservedRegions(kind: .division)` returns the regions overlapping that view. Re-read them in `layoutSubviews` / `viewDidLayoutSubviews`, not once.
- **`.division`** = the display is logically split (content shouldn't straddle it). **`.occlusion`** = something covers part of the display: the outer front camera always, the inner front camera while it's in use.
- Check **`.isActive`** — regions exist but aren't always in effect; pass `.includeInactive` only when you deliberately want to plan for a region that isn't currently applied.
- **Never let an interactive control land in a division or occlusion.** A custom layout that partially closes can otherwise put a button *underneath the fold* — unreachable, and invisible in a screenshot test.

## Vertical Bars (iOS 27.1)

On the outer display, and in the detail column on the inner display, the system merges navigation bar, toolbar, and tab bar into one vertical bar on the hardware side. Only bars owned by a container participate: SwiftUI `.toolbar` inside `NavigationStack` / `NavigationSplitView` / `TabView`; UIKit items on a view controller inside `UINavigationController` / `UITabBarController`. A hand-made `UIToolbar` / `UINavigationBar` / `UITabBar` stays horizontal.

- **Give every item a title and an icon.** Vertical bars show icons, overflow menus show both, and a title-only or custom-view item never goes vertical.
- **Order by purpose:** Back/Close first (`.cancellationAction`; UIKit `leadingItemGroups`), then the prominent action (`.topBarPinnedTrailing`; UIKit `navigationItem.pinnedTrailingGroup`).
- **Plan the overflow.** `.visibilityPriority(.high)` (UIKit `item.visibilityPriority`) keeps frequent and badged items visible longest; put extra actions in `ToolbarOverflowMenu` (UIKit `navigationItem.additionalOverflowItems`), not a second ellipsis menu.
- **Per-item axis:** `.axisBehavior(.horizontalOnly)` keeps an item horizontal; `.verticalPreferred` lets a custom view that fits the bar width go vertical. UIKit: `item.axisBehavior`.
- **Custom UI near the bar** reads `@Environment(\.toolbarVerticalEdge)` / `traitCollection.verticalBarEdge`. The edge follows the hardware, not the layout direction, so never hardcode it.
- **Task-focused screens** can let tabs compress first: `.toolbarVerticalCompressionBehavior(.prefersToolbarItems)` / `navigationItem.verticalBarCompressionBehavior = .prefersBarItems`.
- **Opting out** (`.toolbarVerticalBehavior(.disabled)`, UIKit `preferredVerticalBarBehavior` returning `.disabled`) is for close-only sheets and bottom-heavy single screens like a dial pad. It's a last resort, not a default.

## Multitasking and Multiple Windows

Every app takes part in multitasking on iPhone Duo: side-by-side Split View on the inner display, and a stacked layout of video plus an app. iPhone Mirroring on the Mac resizes apps too. None of these needs special code beyond size classes and scene geometry, but each exposes code that doesn't use them.

- **Treat every size as reachable at any moment.** A Split View slot is narrower than the full inner display and can drop to compact width; the full inner display is regular/regular. Dragging the divider resizes the scene live.
- **Vertical bars can sit on either side** of a Split View slot, so safe areas are asymmetric there even on the inner display.
- **Multiple windows are now an iPhone feature.** Duo is the first iPhone that runs several scenes of one app. iPad multi-window support carries over, so set `UIApplicationSupportsMultipleScenes` deliberately.
- **New windows can't be opened from the outer display.** The ability comes and goes as the device folds. In UIKit use `UIWindowScene.ActivationAction` for "Open in New Window" menu items, because it hides itself when unavailable, and always pass an `errorHandler` to `activateSceneSession(for:errorHandler:)`. In SwiftUI gate the action on `@Environment(\.supportsMultipleWindows)` and don't assume `openWindow` succeeded.
- **Closing the device keeps only the most recently used window active** and backgrounds the others. Each scene must save its own state (`@SceneStorage`, `NSUserActivity`) when it backgrounds.
- **Keep per-window state per scene.** A singleton "current document" breaks the moment two windows show different ones.

## Scene Accessories (iOS 27)

`.sceneAccessory { … }` attaches supplementary content to a view's scene on another display: `ExternalNonInteractiveAccessory` for an external display, `CameraCaptureAccessory` (iOS 27.1) for Duo's outer display while the app captures with the rear camera, full screen on the inner display.

- **Availability is dynamic and system-controlled.** Observe it with `.onAvailabilityChange { … }` and disable the matching control instead of assuming it shows.
- **Attach the accessory to the view that owns the content**, such as the camera view, so it appears and disappears with it.
- Don't plan app content on both Duo displays at once. Outside capture accessories, the outer display shows nothing from your app while the device is open.

## Folded ↔ Unfolded: Continuity Is the Requirement

**The single most important thing: the layout must survive every fold state *and the transitions between them* while state is live.** Opening or closing the device re-flows the layout under a running app — it is a configuration change, not a relaunch.

What must survive a fold, an unfold, and an outer↔inner display switch:

- **Navigation depth and selection** — a screen three levels deep stays three levels deep; the selected row stays selected. On unfold, a pushed detail should *become* the detail pane of a split/arrangement — not pop back to the list. Custom navigation usually gets this wrong; test it explicitly.
- **Text entry and first responder** — in-progress input and cursor position, including inside presented sheets.
- **Scroll position** and list offset.
- **Media playback** position and state.
- **In-flight work** — a running upload or request must not restart.
- **Session identity** — snapping shut mid-task moves the UI to the outer display; the user's session must not reset.
- **Visual stability** — navigation shouldn't visibly jump or re-animate. Interrupted animations and layout jumps are the tell that a transition is rebuilding instead of updating.

Where it breaks:

- **SwiftUI**: `@State` on a view that gets *replaced* when the layout branch flips loses its value. Hoist it above the branch, or key it to content identity rather than layout shape. Use `@SceneStorage` / an observable model for anything that must outlive re-composition.
- **UIKit**: update the existing hierarchy in `traitCollectionDidChange` / `viewWillTransition(to:with:)` — rebuilding it drops first-responder status and scroll offsets.
- **Anything cached from the old geometry** — a stored `isCompact`, a computed column count, a frame captured once — is stale the moment the device folds.
- **Fixed frames** clip content as the window narrows; that's the most common visible symptom.

## Testing

**Simulator (Device Hub).** Install the iPhone Duo runtime via Settings ▸ Components and pick iPhone Duo as a build destination. Toolbar buttons fold and unfold it; **hold ⌥ Option for a precise hinge-angle slider**. To test Split View, drag the app by its home indicator to one side of the inner display, then to the other. Device Hub also resizes any running app by dragging its edges, and Previews has the same resize mode plus a Display group for the alternative display. Xcode 27.2 adds StandBy on iPhone Duo, real multi-finger touch through Sidecar or a touchscreen Mac (for pinch and rotate), and hardware-keyboard simulation.

**Xcode 27.2 Device Hub known issues for Duo:** VoiceOver and the Accessibility Inspector can't read the Duo simulator's screen, so accessibility checks need a device; screenshots can be black for a few minutes after boot; modifier keys can stop working after an outer↔inner switch (click the visible screen).

**The test recipe that actually finds bugs**: navigate several screens deep, open a sheet, start typing — *then* fold and unfold while it's all live. Repeat in both directions and in each orientation. Add Split View on each side, a second window, and free resize.

**What the simulator can't tell you** — budget physical-device time for: VoiceOver and other assistive tech on Duo, camera transitions between outer / inner / rear cameras, one-handed reachability in partially folded poses, haptics, thermal behavior, and how the fold actually looks.

## Common Pitfalls

- **Legacy app lifecycle** — doesn't launch at all against the latest SDK. Migrate to `UIScene`.
- **`UIRequiresFullScreen` treated as an opt-out** — it isn't one anymore; it selects discrete resizing.
- **Idiom or orientation checks driving layout** — wrong on Duo, iPad multitasking, and Mac Catalyst. Use size classes.
- **`UIScreen.main`** anywhere — use the window scene's screen.
- **Force-unwrapping `context.hinge`** — most devices have no hinge, including Duo's outer display.
- **Driving layout from the hinge angle** — structure comes from size classes and arrangements; the angle is animation polish.
- **Computing the fold's position instead of querying `reservedRegions`** — and shipping a control underneath it.
- **Symmetric safe-area math** (`- insets.left * 2`) — inset the rect instead: `view.bounds.inset(by: view.safeAreaInsets)`.
- **Hardcoded sizes, aspect ratios, or corner radii** — multiple display shapes now, and the window is not the display. Use `ConcentricRectangle()` / `UICornerConfiguration` for corners.
- **State lost, animations interrupted, or navigation jumping on fold** — the transition is rebuilding instead of updating.
- **Navigation containers inside an `ArrangementView`**, or an arrangement inside a `List` / scroll view.
- **Custom `UIToolbar` / `UINavigationBar` / `UITabBar`** instead of container-owned bars — they never go vertical. Title-only items don't either.
- **An "Open in New Window" action that ignores availability**, or `activateSceneSession` without an `errorHandler` — it fails on Duo's outer display.
- **UIKit subviews relying on inherited layout margins** after moving to the iOS 27.1+ SDK — they're zero now.
- **iOS 27.1 APIs in a Mac Catalyst target without `#if !targetEnvironment(macCatalyst)`** — the Catalyst build fails on Xcode 27.2.
- **Shipping without physical-device testing** of camera, reachability, and haptics — the simulator covers none of them.
