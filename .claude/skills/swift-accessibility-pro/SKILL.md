---
name: swift-accessibility-pro
description: Deep-reviews Apple app accessibility — the VoiceOver surface (labels, traits, merging, rotor, announcements), Bluetooth assistive input (Full Keyboard Access, Switch Control, braille displays), and visual accessibility (contrast, Dynamic Type, color-independence, Reduce Motion). Use when auditing screens for accessibility, before claiming App Store Accessibility Nutrition Label support, or when reading, writing, or reviewing accessibility code in SwiftUI or UIKit.
license: MIT
metadata:
  author: AppBootstrapAI contributors
  version: "1.1"
  grounded_in: "Apple Accessibility developer documentation, WCAG 2.2 AA, App Store Accessibility Nutrition Label criteria, and the VoiceOver, Dynamic Type, and Sufficient Contrast agent skills Apple ships with Xcode 27 (as published by Artem Novichkov in artemnovichkov/xcode-skills)"
---

Review Apple app accessibility for correctness and completeness. This is the deep-review companion to the always-on `apple-accessibility-best-practices.md` (SwiftUI) and `apple-objc-accessibility-best-practices.md` (UIKit) rules — the rules steer while writing; this skill audits whole screens. Report only genuine problems; don't nitpick.

Applies to SwiftUI and UIKit code. If asked to **write or fix** rather than review, make the changes directly and summarize them in the same file-by-file format.

Review process:

1. Audit the VoiceOver surface using `references/voiceover.md` — what the accessibility tree actually exposes: labels, traits, element merging, rotor/custom actions, focus, announcements.
2. Audit Bluetooth assistive input using `references/bluetooth-input.md` — Full Keyboard Access reachability, Switch Control scan order, braille-display label quality.
3. Audit visual accessibility using `references/visual.md` — contrast ratios, Dynamic Type behavior, color-independence, Reduce Motion, Smart Invert.
4. If the app declares (or plans to declare) App Store Accessibility Nutrition Labels, give each screen a VoiceOver, Larger Text, and Sufficient Contrast verdict with `references/nutrition-label-audit.md` (PASS / FAIL, or NEEDS VERIFICATION for unresolved colors), then verify each claimed feature against what the audit found — a VoiceOver claim requires all common tasks to complete with VoiceOver on.

If doing a partial review, load only the relevant reference files.

## Core Instructions

- **Audit the accessibility tree, not the code style.** The question for every view is what VoiceOver/keyboard/braille users actually receive — trace modifiers to the resulting element, don't assume.
- **The three input methods share one tree.** A fix that adds a `.accessibilityAction` serves the VoiceOver rotor, Switch Control, AND braille users; a missing one fails all three. Report tree problems once, noting every affected input method.
- **Localization is part of accessibility.** Hardcoded English in any a11y attribute is a finding (route through the project's strings facade — see `apple-localization-best-practices.md`).
- **Severity by user impact**: task-blocking (unreachable control, focus trap, missing label on a primary action) > degraded (verbose labels, missing hints, contrast near-misses) > polish (announcement tuning).
- **Name the verification path** for each finding where relevant: Accessibility Inspector, the FKA/Switch Control settings toggles, or on-device VoiceOver — so the developer can confirm the fix.
- Never suggest suppressing or hollowing out an accessibility affordance to silence a finding.

## Output Format

Organize findings by file. For each issue: file/line, the violated principle, affected assistive tech (VoiceOver / keyboard / switch / braille / low-vision), and a brief before/after. Skip clean files. End with a prioritized summary, task-blocking issues first.

Example finding:

### ServiceRow.swift

**Line 24: icon + two text lines exposed as three separate elements — VoiceOver reads the row in fragments; Switch Control scans it as three stops.**

```swift
// Before
HStack {
    Image(systemName: "wifi")
    VStack { Text(service.name); Text(service.host) }
}

// After
HStack {
    Image(systemName: "wifi").accessibilityHidden(true)
    VStack { Text(service.name); Text(service.host) }
}
.accessibilityElement(children: .combine)
```

### Summary

1. **Task-blocking:** custom tap-target views in `ScanView.swift` unreachable under Full Keyboard Access — add `.focusable()` or use `Button`.
2. **Degraded:** 3 compound rows read fragmented; error banner never announced.
3. **Polish:** verbose braille labels on `DetailView` badges.

End of example.

## References

- `references/voiceover.md` — the VoiceOver surface: label/trait/value audit, element merging, rotor + custom actions, focus management, modern announcements.
- `references/bluetooth-input.md` — Full Keyboard Access, Switch Control, and braille displays: reachability, scan order, label quality for braille cells.
- `references/visual.md` — contrast ratios and how to check them, Dynamic Type breakpoints, color-independence, Reduce Motion, Smart Invert.
