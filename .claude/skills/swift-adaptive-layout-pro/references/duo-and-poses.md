# iPhone Duo — arrangements, hinge, reserved regions, continuity

iPhone Duo is a book-style foldable: a 5.4″ outer display that behaves like a standard iPhone, and a 7.6″ inner display that reports **regular width and regular height**. Most Duo bugs are ordinary resizability bugs made visible on a phone; a smaller set are genuinely fold-specific.

> **iOS 27.1 surface.** `ArrangementView`, `onHingeChange` / `UIHingeInteraction`, reserved regions, and vertical bars are iOS 27.1 APIs, introduced in Xcode 27.1 and included in Xcode 27.2's iOS 27.2 SDK. Verify spellings against the SDK in use before flagging their absence.
>
> **Mac Catalyst.** Xcode 27.2 can't compile these APIs for Catalyst yet. A shared iOS/Catalyst target that uses them without `#if !targetEnvironment(macCatalyst)` is a build-breaking finding.

## Arrangements — the two-view container

```swift
ArrangementView {
    VideoPlayer(player: player)          // primary
} secondary: {
    PlaybackControls(player: player)     // secondary
}
.arrangementViewStyle(.split)            // or .overlay
```

- **`.split`** (default) divides the bounds, both regions unobscured. **`.overlay`** floats secondary over primary.
- **UIKit:** `UIArrangementViewController` as the **root view controller of a `UINavigationController`**; set children with `setViewController(_:for: .primary / .secondary)` and the style with `updateArrangement(.split.axes(.horizontal))`.
- **Overlay z-order:** in an overlay arrangement the primary reads `@Environment(\.overlayArrangementZIndex)` (UIKit: `state(for: .primary)?.zIndex`) — 1 while stacked above the secondary, 0 once the fold separates them. Use it to collapse or expand content, not to infer the fold.
- **When the split can't fit** (outer display in landscape), only the primary shows. Essential secondary content needs another route.
- The canonical fit: media in primary, controls in secondary — in tabletop pose the content sits above the fold and the controls below it.

Findings to raise:

- **Navigation containers nested inside an arrangement**, or an **arrangement inside a `List` / scroll view** — both explicitly wrong; arrangements are layout, not navigation.
- **A hand-rolled split that reads the hinge angle to place its divider** — the arrangement adapts around available space *and* the fold already. Re-deriving it is fragile and drops the overlay case.
- **`ArrangementView` where `NavigationSplitView` fits better** — list+detail with selection and back behavior belongs to the split view; arrangements are for two co-resident views.
- **A missing `.arrangementViewStyle(...)` where overlay was intended** — the default is split, so an intended overlay silently renders as a division.

## The hinge is enhancement-only

```swift
.onHingeChange { _, context in
    if let hinge = context.hinge, hinge.status == .partiallyOpen {
        foldEffect = min(max(hinge.angle.degrees / 180, 0), 1)
    } else {
        foldEffect = 0
    }
}
```

- **UIKit:** `UIHingeInteraction(updateHandler:)` added to a view; each `UIHingeInteraction.Update` has an optional `hinge: UIHinge` with `angle` and `status`. Same rules as SwiftUI. Disable it (`isEnabled = false`) when the screen doesn't need it.
- **`context.hinge` is optional.** Every non-folding device — and Duo's own outer display — has none. **Force-unwrapping it is a broken-tier finding** that breaks the whole rest of the lineup, not just an edge case.
- **Layout must never depend on the raw angle.** Structure comes from size classes and arrangements; the angle is animation input only (Apple's "unfold effect" treats the outer display as a window onto the inner one). Flag any layout branch keyed to `angle`.
- `hinge.status` is the coarse signal, `hinge.angle.degrees` the continuous one. Per-degree layout changes read as jitter.
- **Flag posture code that doesn't earn its place** — hinge observation on a settings or list screen is cost without benefit. Note its *absence* only on camera, video, and media screens, where the tabletop stand genuinely matters.

## Reserved regions — query, don't compute

```swift
GeometryReader { proxy in
    let divisions  = proxy.reservedRegions(kind: .division)
    let occlusions = proxy.reservedRegions(kind: .occlusion)
    // each exposes .frame, .margins, .isActive
}
```

- **UIKit:** `view.reservedRegions(kind:options:)` on the view being laid out; re-query in `layoutSubviews` / `viewDidLayoutSubviews`.
- **`.division`** = content shouldn't straddle this (the fold). **`.occlusion`** = something covers the display here: the outer front camera always, the inner front camera while it's in use (touches there are suppressed).
- Check **`.isActive`**; `.includeInactive` only when deliberately planning for a region not currently applied.
- **The high-value finding: an interactive control that can land in a division or occlusion.** A partially-closed device puts it underneath the fold — unreachable, and invisible to screenshot tests. Any custom layout computing the fold's position by hand instead of querying is the same finding upstream.

## Vertical bars

On the outer display, and in the detail column on the inner display, navigation bar, toolbar, and tab bar merge into one vertical bar. System containers handle it. Findings:

- **Custom bars.** A hand-built `UIToolbar` / `UINavigationBar` / `UITabBar`, or a SwiftUI bar faked with an overlay, never goes vertical. Recommend container-owned bars.
- **Items that can't go vertical.** Title-only items and custom views stay horizontal and push into overflow. Every item needs a title *and* an icon (`Button("Compose", systemImage: …)`; UIKit `UIBarButtonItem(title:image:…)`). Badges (`.badge(7)` / `item.badge = .count(7)`) turn text-plus-symbol items into symbol-only ones.
- **Ordering.** Back/Close goes first (`.cancellationAction`; UIKit `leadingItemGroups` with `leftItemsSupplementBackButton = false`), then the prominent action (`.topBarPinnedTrailing`; UIKit `navigationItem.pinnedTrailingGroup`).
- **Overflow.** Frequent and badged items need `.visibilityPriority(.high)` (UIKit `item.visibilityPriority`). A second custom "…" menu should become `ToolbarOverflowMenu` (UIKit `navigationItem.additionalOverflowItems`).
- **Axis overrides.** `.axisBehavior(.horizontalOnly)` for paired items that must stay together, `.verticalPreferred` for a custom view that fits the bar width. UIKit `item.axisBehavior`.
- **Custom UI near the bar** must read `toolbarVerticalEdge` (UIKit `traitCollection.verticalBarEdge`). The edge follows the hardware and doesn't mirror in RTL; a hardcoded edge is a finding.
- **Opt-out** (`.toolbarVerticalBehavior(.disabled)` / `preferredVerticalBarBehavior` → `.disabled`) is legitimate only for close-only sheets and bottom-heavy single screens (dial pad, calculator, full-screen player). Flag it anywhere else, and flag it toggled at runtime.
- **Compression.** `.toolbarVerticalCompressionBehavior(.prefersToolbarItems)` (UIKit `verticalBarCompressionBehavior = .prefersBarItems`) suits task-focused screens where actions matter more than tabs.

## Safe areas are asymmetric

```swift
// ❌ Assumes symmetry — off-center on Duo
let width = view.bounds.width - view.safeAreaInsets.left * 2
// ✅ Inset the rect, then measure it
let width = view.bounds.inset(by: view.safeAreaInsets).width
```

- UIKit: align foreground content to `view.bounds.inset(by: view.safeAreaInsets)`; let backgrounds extend beneath.
- SwiftUI: `.ignoresSafeArea()` on backgrounds only — never on content the user must reach.
- Corners: `ConcentricRectangle()` / `UICornerConfiguration` match the real screen corner. Grep for `safeAreaInsets.<edge>` used individually in arithmetic.

## Camera on two displays

- `CameraCaptureAccessory` for dual-display capture, `AVCaptureDeviceDirectionCoordinator` for device direction, `RotationCoordinator` for preview orientation across display changes.
- **The classic bug**: a preview sized from cached screen bounds or a fixed aspect ratio — stretched the moment the device unfolds. Camera code reading `UIScreen.main.bounds` is broken-tier.

## Continuity across fold and unfold

**The layout must survive every fold state and the transitions between them while state is live.** A fold is a configuration change under a running app.

Trace each of these across fold, unfold, and the outer↔inner switch:

- **Navigation depth + selection** — three screens deep stays three deep. On unfold a pushed detail should *become* the detail pane, not pop to the list. Custom navigation usually breaks this; test it explicitly.
- **Text entry and first responder**, including inside presented sheets.
- **Scroll position**, **media playback position**, **in-flight requests** (must not restart).
- **Session identity** — closing mid-task moves to the outer display; the session must not reset.
- **Visual stability** — no navigation jump, no re-animation. Interrupted animations and layout jumps mean the transition rebuilt instead of updated.

Where it breaks:

- **SwiftUI**: `@State` on a view replaced when the layout branch flips loses its value — hoist above the branch or key to content identity, not layout shape. `@SceneStorage` / an observable model for anything that must outlive re-composition.
- **UIKit**: update the existing hierarchy in `traitCollectionDidChange` / `viewWillTransition(to:with:)`; rebuilding drops first responder and scroll offsets.
- **Anything cached from old geometry** — a stored `isCompact`, a computed column count, a captured frame.
- **Fixed frames** clip as the window narrows — the most common visible symptom.

## Audit sequence

1. Two-view layouts → `ArrangementView` / `NavigationSplitView`? Check nesting constraints and the style modifier.
2. Every `onHingeChange` → optional unwrapped safely? Any layout keyed to `angle`?
3. Custom layouts → do they query `reservedRegions`, and can a control land in one?
4. Grep `safeAreaInsets.<edge>` in arithmetic; grep `UIScreen.main`.
5. Per screen, trace state across a fold: navigation, selection, text, scroll, playback, in-flight work.
6. Walk folded→unfolded *and* unfolded→folded navigation paths; name where continuity breaks.
7. Note what needs a physical device (below) rather than claiming simulator coverage.

## Simulator vs device

The Duo simulator in Device Hub folds/unfolds from toolbar buttons, and **⌥ Option gives a precise hinge-angle slider**. Xcode 27.2 adds StandBy and multi-finger touch through Sidecar or a touchscreen Mac. It does **not** cover: VoiceOver and the Accessibility Inspector (they can't read the Duo simulator in Xcode 27.2), camera transitions between outer / inner / rear cameras, one-handed reachability in partially folded poses, haptics, thermal behavior, or how the fold physically looks. Recommend device time for those rather than signing off from the simulator.
