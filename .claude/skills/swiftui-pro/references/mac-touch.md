# Touch on Mac

macOS 27 accepts direct touch from the touchscreen MacBook Pro and from a Sidecar-connected iPad running iPadOS 27. Review macOS and Mac Catalyst code for it whenever the project targets the Mac. Touch is a secondary input: the pointer and keyboard stay primary, and the layout should not change. The rule `apple-mac-touch.md` holds the full guidance; this file is the review checklist.

Rules marked 27.3 are beta in the current SDK. Use 27.0 APIs only when the deployment target allows, or inside `if #available(macOS 27, *)`. Keep deployment targets unchanged.


## Gestures and input kinds

- Standard controls and SwiftUI gestures already handle touch. Don't flag them, and don't wrap them in touch-specific code.
- Flag any gesture or `onTapGesture` / `onLongPressGesture` restricted to `inputKinds: .pointer` (or `[.pointer, .indirectTouch]`) when it performs an action. Touch users can't reach it. The default, `.all`, is correct for actions.
- Narrowing to `.directTouch` is correct for touch-only affordances, such as a tap that reveals hover controls.
- In shared iOS/visionOS code, flag removal of `.indirectTouch` from a gesture's input kinds: visionOS uses it for look-and-pinch.
- Flag `.directTouchSystemGesturesDisabled()` (27.3) on views that don't need three or more simultaneous touches. It disables system gestures for the whole window. Suggest passing `false` once the multi-touch UI is gone.


## Hover

- Flag essential controls shown only while `.onHover` / `.onContinuousHover` is true, with no touch path. Recommend a tap reveal (`onTapGesture(inputKinds: .directTouch)`) that auto-hides, plus the same action in `.contextMenu`.
- Don't flag `.help` tooltips or other purely informational hover.
- Flag hidden controls made permanently visible as a "touch fix"; the HIG asks for a reveal, not a denser layout.


## Hit targets

- Flag custom tappable glyphs, grips, and handles whose tappable region is under 36×36pt. Suggest a larger `.frame(minWidth:minHeight:)` with `.contentShape(.rect)` around the visual, within existing spacing.
- Don't recommend enlarging standard controls or adding a "touch mode"; standard controls already carry an invisible 36pt touch target.


## AppKit bridges (`NSViewRepresentable`, AppKit views in a SwiftUI app)

- Flag `mouseDown(with:)`, `mouseDragged(with:)`, or `mouseUp(with:)` overrides outside an `NSGestureRecognizer` subclass. AppKit emulates only single-finger taps and drags from them, and on an `NSControl` subclass any such override forces a modal tracking-loop fallback even when it calls `super`. Recommend `NSControl.Events` (`.trackingBegan`, `.primaryActionTriggered`, …) or a gesture recognizer.
- Flag tracking loops (`nextEvent(matching:until:inMode:dequeue:)`, `trackEvents(matching:timeout:mode:handler:)`). Recommend a gesture recognizer, or a touch-only `NSPanGestureRecognizer` with `buttonMask = 0` beside the loop, sharing start/continue/end/cancel functions.
- Flag `NSEvent` monitors or `sendEvent(_:)` overrides used to observe input; touches never reach them.
- Flag `NSApp.currentEvent` in action methods. Use `NSEvent.modifierFlags` and `NSEvent.pressedMouseButtons`.
- Flag custom `NSGestureRecognizer` subclasses missing `touchesCancelled(with:)` / `mouseCancelled(with:)`, `reset()`, or `location(in:)`, or that can stay active without reaching `.ended`, `.failed`, or `.cancelled`. A stuck recognizer blocks every other gesture; a missing `location(in:)` returns `NSZeroPoint` under the 27 SDK.
- Flag transparent overlay views stacked above controls. Recognizers are gathered by hit-testing, so the overlay blocks them; suggest reordering or returning `nil` from `hitTest(_:)`.
- Flag `NSScreen.touchCapabilities` checks that drive layout. They report `true` for every display while a Sidecar iPad is connected.


## Info.plist

- Flag `NSIsTouchNative` in an app built only with AppKit or SwiftUI. It is meant for apps embedding a non-AppKit UI or game framework with their own touch pipeline, and it removes the mouse emulation other apps rely on.
