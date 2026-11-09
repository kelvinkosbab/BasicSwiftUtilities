# Bluetooth assistive input — keyboard, switch, braille

Three input methods, one accessibility tree. The audit question for each screen: can it be *operated* (not just read) without touch?

## Full Keyboard Access (Bluetooth keyboards)

Settings ▸ Accessibility ▸ Keyboards ▸ Full Keyboard Access; then Tab/arrows to move, Space to activate.

- **Reachability**: every interactive element must receive focus. Real controls (`Button`, `Toggle`, `NavigationLink`, `UIControl`) come free. Findings hide in:
  - `.onTapGesture` on plain views — never focusable. Fix: make it a `Button` (preferred) or add `.focusable()` + accessibility traits.
  - UIKit custom views with gesture recognizers — override `canBecomeFocused` → `YES` and handle activation, or rebuild on `UIControl`.
  - Cells whose action lives on a hidden overlay button — focus lands somewhere inert.
- **Activatability**: focus without action is still a failure — verify Space/Return actually triggers the behavior, not just the visual highlight.
- **Focus visibility**: never suppress the system focus indicator; custom focus styling keeps ≥ 3:1 contrast against the surface.
- **Key commands**: primary screen actions benefit from `.keyboardShortcut(_:)` / `UIKeyCommand`. Never claim arrow/Tab keys with `wantsPriorityOverSystemBehavior` — that steals navigation from keyboard users.
- **Traps**: text fields that capture Tab (custom editors), infinite carousels — verify there's a keyboard path OUT of every container.

## Switch Control (Bluetooth switches)

Scanning steps through the accessibility elements in order and activates on switch press.

- **Scan order = element order**: leading→trailing, top→bottom. Audit `ZStack`s, floating buttons, and custom layouts where the tree order diverges from visual logic.
- **Merged rows help scanning**: a fragmented row (see `voiceover.md`) triples the scan stops. The `.combine` fix serves both.
- **Gesture mirrors are mandatory**: swipe/long-press/drag affordances must appear as `.accessibilityActions` (SwiftUI) / `accessibilityCustomActions` (UIKit) — Switch Control surfaces them in its action menu. UIKit custom gesture views also return `YES` from `accessibilityRespondsToUserInteraction`.
- **No inert stops**: elements that scan but do nothing on activation (decorative views left focusable, disabled controls without `.notEnabled` trait) waste every scan cycle.

## Braille displays

Driven by VoiceOver over Bluetooth (HID). There is no braille API — **your labels are the braille output**, rendered on a 14–40 cell line.

- **Front-load meaning**: "Delete scan result" beats "Tap here to delete the scan result" — the tail falls off the display.
- **Short, plain labels**: emoji, decorative punctuation, and ASCII art render as literal braille noise. Flag any label containing them.
- **Distinct prefixes**: in lists, labels that share a long common prefix ("Bonjour service: X", "Bonjour service: Y") force panning on every row — lead with the distinguishing part.
- **Values and states must be textual**: state conveyed only by trait changes or announcements is weaker on braille than speech — prefer `.accessibilityValue` text the display can render.

## Audit sequence

1. Tab through every screen with FKA enabled (or simulate: trace focusable elements in code) — list unreachable/inert controls.
2. Walk the element order per screen — list order breaks and fragmented rows.
3. Grep a11y label/action strings for emoji, length outliers, and hardcoded English.
4. Cross-check every gesture recognizer / `.onTapGesture` / swipe action against the action-mirror list.
