# Touch on Mac (full reference)

The long form of the `apple-mac-touch.md` rule, loaded only when this skill needs the detail. The rule keeps a short checklist; everything below is the complete guidance.

macOS 27 accepts direct touch: from the touchscreen MacBook Pro (announced October 2026) and from any iPad running iPadOS 27 over Sidecar. Your Mac app gets touched whether or not you planned for it. macOS translates touches into clicks, so most apps keep working, but anything built on hover, small hit areas, `mouseDown(with:)` overrides, or tracking loops gets worse with a finger. This rule covers what to change. It installs when `macos` is in `--apple-platforms` (the default).

> **Toolchain.** The APIs below ship in the macOS 27.0 SDK unless marked otherwise. The direct-touch system-gesture opt-outs are **macOS 27.3 (beta)**. Verify spellings against the SDK you build with. Apple's sources: TN3212 (*Adopting gesture recognizers for Sidecar touch support*), the AppKit article *Adopting gesture recognizers in your app*, TN3216 (games), the Tech Talks *Design for touch on Mac* and *Bring Touch to your Mac app*, and the HIG pages *Gestures* and *Pointing devices*.

## Touch Is a Secondary Input

- **Keep layout, density, and control size unchanged.** People reach forward to touch the screen for brief, deliberate actions; the pointer and keyboard stay primary. Don't build a "touch mode" that swells the UI.
- **Make hit targets bigger, not controls.** The touch target on macOS is **36×36pt** (the physical equivalent of 44pt on iOS). Standard controls already have an invisible 36pt touch target; custom views need one too.
- **Never make touch the only way to do something, and never make the pointer the only way either.** Hover-only, right-click-only, and multi-finger-only actions each need another path.
- **Branch on the interaction, not the device.** Handle every input the same way and adjust presentation per gesture. `NSScreen.touchCapabilities.contains(.multiTouch)` exists for genuinely touch-specific features (capturing a signature), but in macOS 27 it reports `true` for **every** display once a Sidecar iPad is connected, so it's useless for "is this a touch Mac?" layout decisions.

## SwiftUI

Standard controls and SwiftUI gestures are touch-native. `Button`, `Toggle`, `Slider`, `Stepper`, `List` selection, `ScrollView`, `.contextMenu`, `.draggable`, and `.dropDestination` need no changes. What does:

### Restrict gestures by input kind (`GestureInputKinds`, 27.0)

```swift
// Every gesture accepts `inputKinds:` (default `.all`).
// Members: .directTouch, .indirectTouch (trackpad), .pointer (mouse/trackpad click), .pencil, .all
TapGesture(count: 1, inputKinds: .directTouch)
DragGesture(minimumDistance: 10, coordinateSpace: .local, inputKinds: [.pointer, .indirectTouch])
LongPressGesture(minimumDuration: 0.5, maximumDistance: 10, inputKinds: .directTouch)

// View modifiers too
.onTapGesture(count: 1, coordinateSpace: .local, inputKinds: .directTouch) { location in … }
.onLongPressGesture(minimumDuration: 0.5, maximumDistance: 10, inputKinds: .directTouch) { … }
```

- **Leave the default (`.all`) for any action.** Narrow it only to add a touch-specific *affordance* (a tap that reveals hover controls) or to keep a touch gesture from colliding with a pointer one. A gesture limited to `.pointer` is an action touch users can't reach.
- `GestureInputKinds` is available on every Apple platform at 27.0, so the same code is correct on iPad (`.pencil` vs `.directTouch`) and visionOS (`.indirectTouch` is the look-and-pinch). Don't drop `.indirectTouch` from a shared gesture without checking visionOS.
- On a deployment target below 27, wrap the `inputKinds:` overloads in `if #available(macOS 27, iOS 27, *)`.

### Hover-only UI needs a touch path

There's no hover on a touch display. `.onHover`, `.onContinuousHover`, `.hoverEffect`, and `.help` tooltips never fire for a finger.

- **Tooltips and other purely informational hover can stay pointer-only.**
- **Essential controls that appear on hover** (a row's delete button, a tab's close button, a toolbar that fades in) need a touch reveal: a tap on the row or region shows them, and they hide again when the interaction ends or after a few seconds idle. Keep the current selection when revealing. Don't solve it by showing them permanently.
- **Mirror hidden actions in `.contextMenu`.** Touch-and-hold opens it, so it's the cheapest guaranteed touch path (and VoiceOver's, via `.accessibilityActions`).

```swift
struct DocumentRow: View {
    @State private var isHovering = false
    @State private var isRevealedByTouch = false
    let document: Document
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(document.title)
            Spacer()
            if isHovering || isRevealedByTouch {
                Button(action: onDelete) { Label(Strings.Actions.delete, icon: .delete) }
                    .labelStyle(.iconOnly)
            }
        }
        .contentShape(.rect)
        .onHover { isHovering = $0 }
        .onTapGesture(inputKinds: .directTouch) { _ in isRevealedByTouch.toggle() }   // touch-only reveal
        .task(id: isRevealedByTouch) {                                           // auto-hide when idle
            guard isRevealedByTouch else { return }
            try? await Task.sleep(for: .seconds(4))
            isRevealedByTouch = false
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) { Label(Strings.Actions.delete, icon: .delete) }
        }
    }
}
```

### Hit targets

- **Prefer standard controls** — they get the 36pt touch target for free.
- **Custom tappable glyphs**: give the tappable region a 36pt minimum with `.frame(minWidth: 36, minHeight: 36)` + `.contentShape(.rect)` around the smaller visual, spending existing spacing rather than growing the layout. Resize grips, drag handles, and timeline edges are the usual offenders.
- Don't add a `.padding` that moves neighbors just to fit a finger; the HIG rule is "same layout, bigger targets."

### Multi-finger interaction and system gestures

- Multi-finger touches on Mac can trigger system gestures (Mission Control, edge swipes) that take precedence over yours. If your UI genuinely needs three or more simultaneous touches (a mixer with several faders, a multi-touch canvas), apply **`.directTouchSystemGesturesDisabled()`** (macOS / Mac Catalyst **27.3, beta**). It affects the **whole window** that contains the view, can't be re-enabled by a descendant, has no effect on trackpad gestures, and is only a preference the system may decline.
- Scope it tightly: apply it to the view that needs it and pass `false` when that UI goes away. Don't disable system gestures app-wide "just in case."
- Pinch and rotate (`MagnifyGesture`, `RotateGesture`) work with touch; keep them on content that already supports trackpad pinch.

## AppKit (and `NSViewRepresentable` bridges)

The big change: **gesture recognizers are the only way to receive direct touches.** Touches never go through the responder chain, `NSApp.sendEvent(_:)`, or local/global event monitors. AppKit only emulates a single-finger tap or drag as mouse events, so legacy event code works with one finger and nothing more.

| Code you have | What happens with touch | Do this |
|---|---|---|
| Standard controls, `NSGestureRecognizer`s | Works | Test it |
| `mouseDown(with:)` / `mouseDragged(with:)` overrides on custom views, or a tracking loop (`nextEvent(matching:until:inMode:dequeue:)`, `trackEvents(matching:timeout:mode:handler:)`) | Single-finger emulation only; no pinch, rotate, or multi-touch | Replace with recognizers, or add a touch-only recognizer beside the loop |
| An `NSButton` / `NSSlider` / `NSControl` subclass overriding **any** left-mouse method (even calling `super`) | The control falls back to a modal tracking loop | Delete the override; observe `NSControl.Events` with `addTarget(_:action:for:)` |
| `mouseDragged(with:)` drag start in `NSTableView` / `NSCollectionView` / `NSOutlineView` / `NSBrowser` | Tracking-loop fallback | Use the data-source/delegate dragging methods (`tableView(_:pasteboardWriterForRow:)`) |
| `NSApp.currentEvent` read in an action method | No longer the triggering event | Read `NSEvent.modifierFlags` / `NSEvent.pressedMouseButtons` (class properties) |
| Custom `NSGestureRecognizer` subclass | Stuck recognizers block every other recognizer | Handle `mouseCancelled(with:)` / `touchesCancelled(with:)`, always reach `.ended` / `.failed` / `.cancelled`, override `reset()` and `location(in:)` |

```swift
// Control side effects without overriding mouse methods (macOS 27):
openButton.addTarget(self, action: #selector(showHighlight), for: [.trackingBegan, .trackingEntered])
openButton.addTarget(self, action: #selector(hideHighlight),
                     for: [.trackingExited, .trackingEndedInside, .trackingEndedOutside, .trackingCancelled])
openButton.addTarget(self, action: #selector(openDocument), for: .primaryActionTriggered)

// Keep an existing tracking loop for the mouse; add touch beside it.
let touchPan = NSPanGestureRecognizer(target: self, action: #selector(touchPan(_:)))
touchPan.buttonMask = 0                 // touch only; otherwise a mouse drag starts it and mouseDown never runs
touchPan.allowedTouchTypes = .direct    // the default, stated explicitly
canvas.addGestureRecognizer(touchPan)

@objc private func touchPan(_ recognizer: NSPanGestureRecognizer) {
    let point = recognizer.location(in: canvas)
    switch recognizer.state {
    case .began:     startTracking(at: point, expandHitRect: true)   // 36pt touch slop
    case .changed:   continueTracking(at: point)
    case .ended:     endTracking(at: point)
    case .cancelled: cancelTracking()                                // undo partial changes
    default:         break
    }
}
```

- **Refactor tracking into `start` / `continue` / `end` / `cancel` functions** so the mouse path and the touch recognizer share one implementation.
- **Filter candidates early**: `gestureRecognizer(_:shouldAttemptToRecognizeWith:)` sees the initiating `NSEvent` (pointer only); `gestureRecognizer(_:shouldReceive:)` sees each `NSTouch` (the only filter for direct touch). Use them to scope one recognizer to a grip or a clip instead of adding tiny views, and to accept touches landing just outside a small visual.
- **Occluding views block recognizers.** Recognizers are gathered by hit-testing down the view hierarchy, not the responder chain, so a transparent overlay above a control (including standard controls, which now use recognizers internally) kills its input. Reorder siblings or return `nil` from the overlay's `hitTest(_:)`.
- **Context menus**: set `NSView.menu` or override `menu(for:)` instead of showing a menu from `mouseDown(with:)`. AppKit then wires touch-and-hold and Control-click, and coordinates long-press with dragging.
- **Exclusivity**: by default AppKit lets one view hierarchy handle gestures at a time (scrolling excepted), mimicking tracking-loop modality. Allow simultaneous interaction (several sliders at once) per view with `NSView.exclusiveGestureBehavior = .notExclusive`, or app-wide with the `NSViewGestureRecognizerIsExclusive` Info.plist key.
- **Scrolling (27.0)**: `NSScrollView.isTouchScrollingEnabled`, `minimumNumberOfTouchesForScrolling` / `maximumNumberOfTouchesForScrolling` (e.g. require two fingers on a drawing canvas), `NSRefreshController` for pull-to-refresh, and `NSGestureRecognizer.isCancellableByScrollGesture = true` for buttons inside scroll views. `NSPanGestureRecognizer.minimumNumberOfTouches` / `maximumNumberOfTouches` replace the deprecated `numberOfTouchesRequired`.
- **Dragging and text (27.0)**: start drags from a recognizer with `beginDraggingSession(items:gesture:source:)`. Custom text engines adopt `NSTextSelectionManager` for standard touch selection gestures.
- **Swipes**: AppKit doesn't translate touch swipes into `trackSwipeEvent(…)`. For back/forward page swipes, check `NSEvent.isTouchSwipeNavigationEnabled` and implement the swipe yourself.
- **Hover** stays on `NSTrackingArea` + `mouseMoved(with:)`, pointer only; apply the hover-reveal rules above.
- **System gestures**: `NSWindow.disablesDirectTouchSystemGestures` (27.3, beta), same scoping rules as the SwiftUI modifier.

## Mac Catalyst

UIKit touch handling (`UIGestureRecognizer`, `allowedTouchTypes`, `UITouch.type`) carries over. Use `UIViewController.prefersDirectTouchSystemGesturesDisabled` (27.3, beta) for the system-gesture opt-out, overriding it only on the view controller that needs simultaneous multi-finger input.

## Info.plist Keys

- **`NSIsTouchNative`** (macOS 27.0) turns off AppKit's extra mouse emulation for apps that **embed a non-AppKit UI or game framework** with their own touch pipeline. Most AppKit and SwiftUI apps must **not** set it. Add it only once your framework handles touch natively.
- **`NSViewGestureRecognizerIsExclusive`** sets the app-wide gesture exclusivity default (above).

## Games

TN3216 covers games. In short: touch extends the Mac experience for brief, one-handed actions (inventory, map zoom, menus), not as a full control scheme. With `LSApplicationCategoryType` set to a games category, AppKit sends a `mouseMoved(with:)` to the touch location before each emulated click, so read absolute positions from events instead of summing deltas. Each touch surface shows up as an extra `GCMouse` with no scroll, pinch, or extra buttons. For real touch input, set `NSIsTouchNative`, install tap, pan (`buttonMask = 0`), and magnification recognizers once on the game view, and convert their callbacks (scaled by the backing scale factor, y-flipped if needed) into engine input. Don't override `sendEvent(_:)` or run `nextEvent(matching:…)` loops.

## Testing

- **Sidecar is the test rig.** Connect an iPad running iPadOS 27 to a Mac on macOS 27; AppKit routes its touches exactly as a touch display does. No touchscreen Mac required.
- **Touch every window, sheet, and popover**: controls highlight and activate on tap; one-finger drag, text selection, and scrolling work; pinch and rotate work where supported; resize grips and handles are hittable; hidden hover controls are reachable; the app stays responsive after an interaction ends.
- **Grep for the risky code**: `mouseDown(with:`, `mouseDragged(with:`, `mouseUp(with:`, `nextEvent(matching:`, `trackEvents(matching:`, `currentEvent`, `.onHover`, `.onContinuousHover`. `install.sh audit` flags the AppKit ones.
- **Catch stuck recognizers in debug builds** with the `NSGestureRecognizerCrashOnMissingOverrides` and `NSCrashOnStuckGestureTimeout` user defaults from Apple's AppKit migration article. Never ship them. By default the system cancels a recognizer that hasn't ended about two seconds after the person stops interacting.

## Common Pitfalls

- **A "touch mode" that enlarges controls** — the HIG says enlarge targets, keep the layout.
- **Essential controls that only appear on hover** — unreachable by touch. Add a tap reveal and a context-menu entry.
- **`inputKinds: .pointer` on an action** — touch users can't do it.
- **`touchCapabilities` checks driving layout** — true for every display with Sidecar attached.
- **`mouseDown(with:)` overrides on `NSControl` subclasses "that call super"** — still forces the tracking-loop fallback.
- **Event monitors or `sendEvent(_:)` to catch input** — touches never arrive there.
- **A transparent overlay above controls** — blocks their recognizers.
- **Custom recognizers that never reach a terminal state or skip `location(in:)`** — freeze other gestures; return `NSZeroPoint` under the 27 SDK.
- **`NSIsTouchNative` set in an AppKit/SwiftUI app** — removes emulation the app was relying on.
- **Disabling system gestures window-wide for a single-finger UI.**
