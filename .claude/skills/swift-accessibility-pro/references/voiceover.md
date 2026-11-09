# The VoiceOver surface

Audit what the accessibility tree exposes, element by element. VoiceOver reads the tree, not the layout — a screen that looks fine can be unusable if the tree is fragmented, unlabeled, or trapped.

## Labels, traits, values

- **Every interactive element needs a label** that survives out of visual context: "Delete scan" not "Delete" when three deletes exist on screen. Labels are nouns/noun phrases; the trait supplies "button".
- **Traits carry the role**: `.isButton`, `.isHeader`, `.isSelected`, `.isToggle` (SwiftUI adds most automatically for real controls — custom gesture views get nothing and must add them). A `Text` with `.onTapGesture` and no traits is invisible as a control — the classic finding.
- **Values for stateful controls**: sliders, steppers, custom toggles need `.accessibilityValue` that updates with state. Check the update actually happens — a value captured once at init is a stale-state bug.
- **Hints only where the label leaves ambiguity** — and phrased as outcomes ("Deletes the scan"), not instructions ("Double-tap to delete"; VoiceOver appends its own interaction hints).
- **Hidden means hidden**: decorative images `.accessibilityHidden(true)`; but verify nothing *interactive* got swept into a hidden container — hiding a parent hides the subtree.

## Element structure — merging and order

- **Compound rows merge**: icon + title + subtitle = one element via `.accessibilityElement(children: .combine)` with a coherent combined label. Fragmented rows triple the swipe count for every list.
- **Reading order follows layout order** — check `ZStack`s and custom layouts where visual order ≠ structural order; fix with `.accessibilitySortPriority(_:)` sparingly.
- **Headers gate navigation**: section titles need `.isHeader` — VoiceOver users navigate by heading rotor first. A screen with zero headers forces linear swiping through everything.
- **Modals must contain focus**: custom overlays (not `.sheet`/`.alert`) need `.accessibilityAddTraits(.isModal)` or focus escapes to the dimmed background.

## Rotor and custom actions

- **Every gesture-only affordance needs an `.accessibilityAction` mirror**: swipe-to-delete, long-press menus, drag handles, double-tap shortcuts. Context menus are NOT in the default rotor — mirror their items.
- Custom actions use localized, verb-first names. The same mirror serves Switch Control (see `bluetooth-input.md`).
- For data-dense screens, consider `.accessibilityRotor(_:entries:)` to let users jump between semantic entries (unread items, errors) — flag its absence only when the screen genuinely warrants it.

## Focus management

- **Dismissal returns focus** to the presenting element. SwiftUI mostly handles it; custom presentation/dismissal animation is where it breaks — verify.
- **`@AccessibilityFocusState`** moves focus deliberately (first error after failed submit, new content after refresh). Flag both its absence where users would be lost AND its overuse — unrequested focus jumps disorient.
- **Never trap focus**: a custom carousel/pager that swallows swipe gestures can strand VoiceOver users. Check escape paths.

## Announcements

- Modern API: `AccessibilityNotification.Announcement("Saved").post()` (iOS 17+). Legacy `UIAccessibility.post(notification: .announcement, ...)` in SwiftUI code is a finding.
- **Priority via `AttributedString`** + `accessibilitySpeechAnnouncementPriority`: errors = high (must not be interrupted), progress ticks = low (droppable).
- **Announce state the UI doesn't already speak.** If the change updates a focused element's label/value, an announcement double-speaks — flag it. Streamed text (AI chat) must NOT announce per token; see the streaming section of the a11y rule.
- Screen-level changes use `AccessibilityNotification.ScreenChanged`; layout shifts use `.LayoutChanged` with the element to focus.

## UIKit deltas

Same audit through the property surface: `isAccessibilityElement`, `accessibilityLabel/Value/Traits`, `accessibilityElements` (order), `accessibilityViewIsModal`, `accessibilityCustomActions`, `UIAccessibilityPostNotification`. Dynamic state must update traits via overridden getters, not one-shot assignment in `init` — see `apple-objc-accessibility-best-practices.md` for the full property reference.
