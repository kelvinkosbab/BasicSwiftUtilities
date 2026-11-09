---
description: Support touch on Mac (touchscreen MacBook Pro and Sidecar on iPadOS 27) — touch as a secondary input, 36pt hit targets without bigger controls, SwiftUI GestureInputKinds, touch reveals for hover-only UI, AppKit gesture recognizers instead of mouseDown overrides and tracking loops, and Sidecar testing
globs: "**/*.{swift,h,m,mm,plist}"
paths:
  - "**/*.{swift,h,m,mm,plist}"
must:
  - "Touch is secondary input: same layout and control sizes, 36pt hit targets, every action reachable by pointer and touch."
  - "Branch on the interaction, not `NSScreen.touchCapabilities`."
  - "Essential hover-only controls need a tap reveal and a context-menu entry."
  - "AppKit receives touches only through gesture recognizers; avoid `mouseDown` overrides and tracking loops."
---

# Touch on Mac

macOS 27 accepts touch from the touchscreen MacBook Pro and from Sidecar on iPadOS 27. This is the checklist; the full rule with SwiftUI and AppKit code, Mac Catalyst, games, and Info.plist keys is in [`mac-touch-conventions.md`](../skills/swiftui-pro/references/mac-touch-conventions.md), and `swiftui-pro` reviews with it.

## Touch is a secondary input

- **Keep layout, density, and control sizes.** No "touch mode" that enlarges the UI.
- **36×36pt hit targets.** Standard controls have them; custom tappable views get `.frame(minWidth: 36, minHeight: 36)` + `.contentShape(.rect)` around the smaller visual.
- **Every action works by pointer and by touch.** No hover-only, right-click-only, or multi-finger-only action.
- **Branch on the interaction, not the device.** `NSScreen.touchCapabilities` is true for every display once Sidecar connects; keep it for touch-only features such as signature capture.

## SwiftUI

- **Leave gestures at `inputKinds: .all`.** Narrow with `GestureInputKinds` only to add a touch affordance or avoid a collision; `.pointer` on an action locks touch out.
- **Hover-revealed essential controls** get a tap reveal that hides again when idle, plus a `.contextMenu` entry. Tooltips can stay pointer-only.
- **`.directTouchSystemGesturesDisabled()`** (27.3 beta) is window-wide; use it only for 3+ simultaneous touches.

## AppKit

- **Gesture recognizers are the only way to receive touches.** `mouseDown(with:)` overrides and `nextEvent(matching:)` tracking loops get single-finger emulation, and any mouse override on an `NSControl` subclass forces the tracking-loop fallback, even when it calls `super`.
- **Use `NSControl.Events`, delegate drag methods, or a touch-only recognizer (`buttonMask = 0`)**, sharing one start/continue/end/cancel implementation with the mouse path.
- **Menus via `NSView.menu` or `menu(for:)`**, not from `mouseDown`. Event monitors and `sendEvent(_:)` never see touches.
- **No transparent overlays above controls**; they block recognizers gathered by hit-testing.
- **Custom recognizers** reach a terminal state and override `location(in:)`.
- **`NSIsTouchNative`** only for apps embedding a non-AppKit UI or game framework. Games follow TN3216.

## Testing

- Use Sidecar as the rig and touch every window, sheet, and popover. Grep for `mouseDown(with:`, `mouseDragged(with:`, `nextEvent(matching:`, `trackEvents(matching:`, `.onHover`; `install.sh audit` flags the AppKit ones.
