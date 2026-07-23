---
description: Enforce SwiftUI accessibility best practices for VoiceOver, Dynamic Type, Reduce Motion, and Bluetooth assistive tech (keyboards, switches, braille displays, hearing devices)
globs: "**/*.swift"
---

# Accessibility Best Practices

All views must be fully accessible. VoiceOver, Dynamic Type, and Reduce Motion support are required, not optional — and so is working with the Bluetooth assistive hardware VoiceOver users pair: external keyboards (Full Keyboard Access), switches (Switch Control), and refreshable braille displays.

## VoiceOver Labels & Hints

- Every interactive element (Button, Toggle, Picker, NavigationLink) must have an `.accessibilityLabel` if its purpose isn't clear from its visible text.
- Add `.accessibilityHint` when the action isn't obvious from the label alone (e.g., destructive actions, toggles that affect other UI, long-press gestures).
- Compound views (HStack/VStack with icon + text) must use `.accessibilityElement(children: .combine)` so VoiceOver reads them as a single element.
- Decorative icons must use `.accessibilityHidden(true)`.

## Localization

- **Never hardcode English strings** in accessibility attributes. All `.accessibilityLabel`, `.accessibilityHint`, and `.accessibilityActions` text must use `Strings.Accessibility.*` from `BonjourLocalization`.
- Use `String(localized:)` for `LocalizedStringResource` values and format functions like `Strings.Accessibility.copyField(name)` for dynamic content.

## Section Headers

- All `Section` header views must include `.accessibilityAddTraits(.isHeader)` so VoiceOver users can navigate by heading.

## Accessibility Actions

- Rows with context menus must also provide `.accessibilityActions` with the same options, since context menus aren't discoverable via VoiceOver's default rotor.
- Use localized action labels from `Strings.Accessibility.*` (e.g., `.copyRecord`, `.editRecord`, `.deleteRecord`).

## Accessibility Identifiers

- Add `.accessibilityIdentifier` to key interactive elements (toolbar buttons, form submit buttons) for UI testing.

## Dynamic Type

- Use semantic fonts (`.font(.headline)`, `.font(.body)`) — never `.font(.system(size:))`.
- Compound layouts (icon + title + detail) should switch from `HStack` to `VStack` at larger Dynamic Type sizes using `@Environment(\.dynamicTypeSize)`.
- Cap Dynamic Type on compact UI elements with `.dynamicTypeSize(...DynamicTypeSize.xxxLarge)` or `.accessibility1` where layout would break.

## Reduce Motion

- Always check `@Environment(\.accessibilityReduceMotion)` before animating.
- Use `withAnimation(reduceMotion ? nil : .default)` instead of bare `withAnimation`.
- This applies to show/hide transitions, state changes, and any animated UI updates.

## Pickers with Hidden Labels

- When using `.labelsHidden()` on a `Picker` inside `LabeledContent`, add `.accessibilityLabel` directly to the `Picker` to restore VoiceOver context that `.labelsHidden()` strips.

## Disabled State Hints

- Buttons with `.disabled` conditions should provide `.accessibilityHint` explaining why the button is disabled (e.g., "Complete all required fields to enable this button").

## Bluetooth Assistive Tech (Keyboard, Switch, Braille)

VoiceOver users routinely pair Bluetooth hardware. Supporting it is mostly *not* extra API — it's making sure the accessibility tree you already built holds up under three more input methods:

- **Full Keyboard Access (Bluetooth keyboards).** Every interactive element must be reachable and activatable by keyboard alone. Standard controls come free; custom tap-target views (`.onTapGesture` on a plain view) do not — give them `.focusable()` plus an accessibility role, or better, make them real `Button`s. Never suppress the system focus indicator. Test: Settings ▸ Accessibility ▸ Keyboards ▸ Full Keyboard Access, then Tab through every screen.
- **Switch Control (Bluetooth switches).** Scanning follows the accessibility element order — keep it logical (leading → trailing, top → bottom) and don't strand focusable elements inside hidden/offscreen containers. Gesture-only affordances (swipe actions, long-press, drag) must be mirrored as `.accessibilityActions` — the same rule that serves the VoiceOver rotor serves switch users.
- **Braille displays.** Driven by VoiceOver over Bluetooth; there is no separate braille API — your labels *are* the braille output. Front-load labels with the meaningful words (a display shows 14–40 cells), keep them short, and never put emoji or decorative punctuation in `.accessibilityLabel` — it renders as literal braille noise.

## Focus Management

- When a sheet, alert, or popover dismisses, focus must return to the element that presented it. SwiftUI usually handles this; verify it after custom presentation/dismissal animations.
- Use `@AccessibilityFocusState` to move VoiceOver focus deliberately after state changes (e.g., onto the first error in a failed form submit) — and use it sparingly; unrequested focus jumps disorient users.

## Announcements

- Use the modern API: `AccessibilityNotification.Announcement("Saved").post()` (iOS 17+) instead of `UIAccessibility.post(notification: .announcement, ...)` in SwiftUI code.
- Set priority via `AttributedString` with `accessibilitySpeechAnnouncementPriority` when an announcement must not be interrupted (errors) or may be dropped (progress ticks).
- Announce sparingly — every announcement interrupts speech and braille output. State that's visible in a label/value doesn't also need an announcement.

## Audio & Hearing

- **Never convey information through sound alone.** Pair every audio cue with a visual change and, where it matters, a haptic (`.sensoryFeedback`). Bluetooth hearing devices and muted phones both make audio an unreliable channel.
- Media playback must support captions/subtitles. `AVPlayer` honors the system Closed Captions + SDH setting automatically; custom players must check `UIAccessibility.isClosedCaptioningEnabled` rather than inventing a parallel toggle.

## Accessibility Nutrition Labels (App Store)

- App Store product pages now show which accessibility features an app supports (VoiceOver, Voice Control, Larger Text, Sufficient Contrast, Reduced Motion, captions). **Declare only what's true**: claiming VoiceOver support means *all common tasks* complete with VoiceOver on — Apple defines the criteria per feature.
- Re-audit the label claims on every release that touches UI; a stale claim is worse than no claim. Treat the label as the release-checklist output of the rules in this file, not marketing copy.

## Streaming AI Text (Foundation Models / chat UIs)

- While a response is generating, set `.accessibilityLabel` to a localized "thinking" string (e.g., `Strings.Accessibility.chatAssistantThinking`). Once the stream completes, swap to the final content.
- **Do not announce every streamed token** — VoiceOver will stutter and interrupt itself. Let the final label update carry the message.
- Decorative "typing" indicators (animated dots, shimmering placeholders) must use `.accessibilityHidden(true)`; the label on the parent element already communicates state.
- Error banners for AI failures must be focusable and announced — use `.accessibilityLabel` with the localized error and `.accessibilityAddTraits(.isStaticText)`.
- Respect `@Environment(\.accessibilityReduceMotion)` for typing-indicator animations — disable the shimmer when motion is reduced.

## Patterns to Follow

```swift
// Compound element
HStack {
    Image(systemName: "wifi").accessibilityHidden(true)
    VStack { Text(title); Text(detail) }
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(title), \(detail)")

// Section header
Section {
    // content
} header: {
    Text(Strings.Sections.title)
        .accessibilityAddTraits(.isHeader)
}

// Animated toggle respecting Reduce Motion
Toggle("Label", isOn: $binding)
    .onChange(of: binding) {
        withAnimation(reduceMotion ? nil : .default) { ... }
    }

// Picker with hidden label
Picker("Label", selection: $value) { ... }
    .labelsHidden()
    .accessibilityLabel("Label")

// Context menu with matching accessibility actions
.contextMenu {
    Button { copy() } label: { Label("Copy", systemImage: "doc.on.doc") }
}
.accessibilityActions {
    Button(String(localized: Strings.Accessibility.copyRecord)) { copy() }
}
```
