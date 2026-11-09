---
name: swift-design-system-pro
description: Bootstraps or audits an Apple app's design system and iconography — SF Symbol facade and custom symbols, app icon (Icon Composer, Liquid Glass appearances), color/type/spacing/shape tokens, component styles, Liquid Glass adoption, and previews. Use when setting up the UI foundation of a new SwiftUI app, when consolidating an existing app's hardcoded colors, fonts, and one-off components, or when reading, writing, or reviewing icon, theme, or shared-component code.
license: MIT
metadata:
  author: AppBootstrapAI contributors
  version: "1.0"
  grounded_in: "Apple Human Interface Guidelines (Icons, SF Symbols, Color, Typography, Materials), SF Symbols app, Icon Composer, SwiftUI style protocols, Liquid Glass adoption guidance (iOS 26+ SDKs)"
---

Set up or review the UI foundation of an Apple app: icons, tokens, and core components. This is the deep companion to the always-on `apple-iconography.md` and `apple-design-system.md` rules — the rules steer while writing; this skill scaffolds a design system from scratch or audits a whole app against one.

Applies to SwiftUI (with UIKit interop notes). Pick the mode from the request:

- **Bootstrap** — a new app, or an app with no design-system module: generate the module skeleton using `references/bootstrap.md`, then fill tokens and components with the user's brand inputs (accent color, brand font, corner style). Ask only for inputs you can't infer; default to system colors and text styles when none are given, and say so.
- **Audit** — an existing app: find and rank what breaks Dark Mode, Dynamic Type, Increase Contrast, RTL, VoiceOver, and visual consistency; propose an incremental migration.
- **Write/fix** — make the changes directly and summarize them in the same file-by-file format.

Review process (audit mode):

1. Inventory with the searches in `references/bootstrap.md` ("Audit searches") — literal colors, fixed font sizes, raw symbol strings, `Bundle.main` asset loads, one-off button implementations. Count before reading files; the counts set priorities.
2. Audit icons using `references/iconography.md` — symbol facade, availability, sizing, rendering modes, effects, custom symbols, icon accessibility, the app icon.
3. Audit tokens and theming using `references/tokens-and-theming.md` — color roles and appearance variants, type scale and custom fonts, spacing/shape scales, Liquid Glass adoption, environment theming.
4. Audit components using `references/components.md` — styles vs wrapper views, duplicates to converge, statelessness, built-in accessibility, previews and the gallery.

If doing a partial review, load only the relevant reference files.

## Core Instructions

- **Meaning over pixels.** Tokens and icons are named by role (`surfaceElevated`, `.delete`), never by value (`gray200`, `"trash"`). A finding that just swaps one literal for another literal is not a fix.
- **System first.** Prefer system semantic colors, text styles, SF Symbols, system button styles, and system containers; every custom piece is something the team maintains through each OS release. Recommend custom only where the system genuinely has no equivalent.
- **Adaptation is the test.** For every token and component ask: does it survive Dark Mode, Increase Contrast, the largest accessibility text size, RTL, Reduce Motion/Transparency, and a window resize? Report the setting that breaks it.
- **The design system is a module with a direction.** It depends on nothing app-specific; features depend on it. Flag inverted dependencies (components importing feature models or view models).
- **Incremental, never big-bang.** Migration plans move one screen or one token family at a time and keep the app shipping; never propose a rewrite of every view in one pass.
- **Severity by user impact**: broken (invisible text/icon in an appearance, blank symbol, truncated controls at large text, unlabeled icon-only control, app icon rejected) > inconsistent (duplicate components, off-scale spacing, mixed symbol styles) > polish (rendering-mode tuning, effect choice).
- Cross-reference, don't duplicate: deep VoiceOver/keyboard audits belong to `swift-accessibility-pro`; view-body performance and modern-API sweeps to `swiftui-pro`; resizable-window behavior to `swift-adaptive-layout-pro`.

## Output Format

**Bootstrap mode:** list the files created (module path → purpose), the brand inputs used (or the defaults chosen), and the next three adoption steps.

**Audit mode:** organize findings by file. For each issue: file/line, the violated principle, the setting or user affected (Dark Mode / AX text size / Increase Contrast / RTL / VoiceOver / consistency), and a brief before/after. Skip clean files. End with an inventory table (literal colors, fixed fonts, raw symbol strings, duplicate components — counts) and a prioritized migration plan.

Example finding:

### CheckoutView.swift

**Line 41: icon-only button built from a raw symbol string at a fixed frame — blank if the name is wrong, frozen at 20pt for large-text users, announced only as "button".**

```swift
// Before
Button(action: removeItem) {
    Image(systemName: "trash").resizable().frame(width: 20, height: 20)
}

// After
Button(action: removeItem) {
    Label(Strings.Cart.removeItem, icon: .delete)
}
.labelStyle(.iconOnly)
.font(.body)
```

### Summary

| Inventory | Count |
|---|---|
| Literal colors (`Color(red:` / hex) | 37 |
| Fixed font sizes (`.system(size:`) | 22 |
| Raw `systemName:` strings | 58 |
| Distinct primary-button implementations | 4 |

1. **Broken:** `Color(white: 0.2)` text on `Color(.systemBackground)` in 6 views — invisible in Dark Mode. Introduce `textPrimary` / `surface` tokens.
2. **Broken:** 3 icon-only buttons with no label.
3. **Inconsistent:** 4 primary-button implementations — converge on a `PrimaryButtonStyle` in `DesignSystem`.
4. **Polish:** hierarchical rendering for toolbar symbols.

End of example.

## References

- `references/iconography.md` — SF Symbol facade and availability testing, sizing via font, rendering modes/variants/variable values, symbol effects and Reduce Motion, custom symbol workflow, icon accessibility, app icons with Icon Composer.
- `references/tokens-and-theming.md` — color roles and asset-catalog variants, type scale and custom fonts with Dynamic Type, spacing/shape scales, concentric corners, Liquid Glass adoption, environment theming.
- `references/components.md` — style protocols vs wrapper views, the core component set, slot APIs, statelessness, accessibility baked in, previews, the gallery, snapshot testing.
- `references/bootstrap.md` — the DesignSystem module skeleton (files and starter code), Package.swift wiring, audit searches, and the incremental migration playbook.
