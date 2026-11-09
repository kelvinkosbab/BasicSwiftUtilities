# Branching on space, not on device

Every layout decision answers one question: *how much room do I have right now?* Anything that answers a different question — what device is this, which way is it turned, how big is the screen — is a finding.

## The three removals

**1. Idiom checks.** `UIDevice.current.userInterfaceIdiom`, `traitCollection.userInterfaceIdiom`, `#if targetEnvironment(macCatalyst)` used for *layout*:

```swift
// ❌ The idiom no longer implies available space.
if UIDevice.current.userInterfaceIdiom == .pad { showSidebar() }

// ✅
if traitCollection.horizontalSizeClass == .regular { showSidebar() }
```

The iPhone Duo's inner display reports **regular width and regular height** — sidebars are appropriate — while remaining an iPhone. An idiom check gets this exactly backwards. Conversely, an iPad in a narrow Split View slot is compact; idiom says "pad" and the space says otherwise.

**2. Orientation checks.** `UIDevice.current.orientation`, `interfaceOrientation`, `UIInterfaceOrientationIsLandscape`, and `supportedInterfaceOrientations` consulted to pick a layout. The inner display does not honor supported orientations for resizable apps, and orientation is downstream of window shape anyway. Branch on size classes (and, where it genuinely matters, the aspect of the *current* geometry).

**3. `UIScreen.main`.** Ambiguous on a two-display device and deprecated:

```swift
// ❌
let scale = UIScreen.main.scale
let w = UIScreen.main.bounds.width

// ✅ Screen from the scene; scale from traits; size from local geometry.
let screen = window?.windowScene?.screen
let scale  = traitCollection.displayScale
```

Also flag `UIScreen.main.bounds` used as a proxy for "how wide is my view" — the window is not the display under multitasking, resize, or an unfolded Duo. Use the view's own `bounds`, `GeometryReader`, or `containerRelativeFrame()`.

## What size classes actually tell you

- **Regular width** → there is room for a sidebar / two-column layout. **Compact width** → one column.
- **Height classes matter too** — a landscape phone is compact-height; don't stack tall content there.
- Size classes are *coarse by design*. When you need a real number (a grid's column count, a max content width), read local geometry — don't invent finer-grained pseudo-classes from screen dimensions.
- **Read them at the level that owns the layout decision**, then pass the decision down. Re-reading the environment in every leaf view scatters the policy and makes it inconsistent.

## Containers that adapt for free

Recommend these before hand-rolled conditionals — they handle resize, fold, and back-navigation:

| Need | SwiftUI | UIKit |
|---|---|---|
| List + detail | `NavigationSplitView` | `UISplitViewController` |
| Top-level sections | `TabView` (+ `.defaultTabBarPlacement(.sidebar)`) | `UITabBarController` (+ `sidebar.preferredPlacement`) |
| Two views around the fold | `ArrangementView` (iOS 27.1) | `UIArrangementViewController` (iOS 27.1) |
| Transient content | sheets, popovers, alerts, context menus | same |

- **Standalone UIKit bars don't adapt.** A bare `UIToolbar` / `UINavigationBar` outside a navigation or tab container misses the system's vertical-bar and edge-to-edge treatment. Host it properly.
- A custom two-pane implementation that reimplements `NavigationSplitView` is a finding when it also loses selection on resize — check that specifically.

## Sizing content

- **Cap content width on wide layouts.** Body text stretched across an unfolded Duo or a full-width iPad is a readability regression; constrain with `frame(maxWidth:)` or a split/arrangement container.
- **Adaptive grids over fixed column counts**: `LazyVGrid(columns: [GridItem(.adaptive(minimum:))])` beats `if regular { 3 } else { 1 }`.
- **Hardcoded frames, aspect ratios, and corner radii** are findings on a device with two display shapes — use `ConcentricRectangle()` / `UICornerConfiguration` for corners, and intrinsic sizing or geometry for the rest.
- **Dynamic Type interacts with this**: a layout that only breaks at large accessibility sizes *and* compact width is a real combination now. Cross-reference `swift-accessibility-pro` rather than re-auditing a11y here.

## Audit sequence

1. Grep for `userInterfaceIdiom`, `UIScreen.main`, `UIDevice.current.orientation`, `interfaceOrientation`, `isLandscape` — every hit that influences layout is a finding.
2. Find layout branches and check each reads a size class (or real geometry), not a proxy.
3. For each screen: which canonical container does it want, and does it use it?
4. Grep for hardcoded frames/aspect ratios/corner radii in view code.
5. Check size-class reads happen at the decision owner, not scattered through leaves.
