# Visual accessibility — contrast, Dynamic Type, color, motion

Low-vision users outnumber VoiceOver users by an order of magnitude. This audit is about what the *sighted-but-low-vision* user gets.

## Contrast

- **WCAG AA ratios**: 4.5:1 for body text, 3:1 for large text (≥ 18pt regular or ≥ 14pt bold) and for essential non-text UI (focus rings, control boundaries, icons that carry meaning).
- **Audit both appearances.** Contrast failures cluster in the theme the team doesn't develop in — dark mode's low-opacity secondary text on elevated surfaces is the classic. Use Accessibility Inspector's color-contrast calculator per screen, per theme.
- **Semantic colors pass for free**: `Color.primary/.secondary`, the `UIColor.label`/`systemBackground` families adapt to dark mode AND Increase Contrast. Hardcoded hex values are findings unless the ratio is verified in both themes — and brand colors on tinted buttons are the usual offenders.
- **Increase Contrast support**: `@Environment(\.colorSchemeContrast) == .increased` (SwiftUI) / `UIAccessibilityDarkerSystemColorsEnabled()` (UIKit) → strengthen hairlines, raise text opacity, add borders to borderless buttons. Absence is a degraded-tier finding, not task-blocking.
- **Text over images/gradients** needs a scrim or minimum-luminance guarantee — a ratio that holds on one photo fails on the next.

## Dynamic Type

- **Semantic fonts only**: `.font(.headline)` / `preferredFontForTextStyle:` + `adjustsFontForContentSizeCategory`. Any `.font(.system(size:))` / `systemFontOfSize:` for user-visible text is a finding.
- **Layout at AX sizes**: at accessibility sizes (AX1–AX5), horizontal icon+text rows should reflow vertically — check for `@Environment(\.dynamicTypeSize)`-driven layout switches on compound rows. Truncated critical text at large sizes is task-blocking.
- **Caps are exceptions, not habit**: `.dynamicTypeSize(...DynamicTypeSize.xxxLarge)` is legitimate on genuinely constrained UI (tab bars, badges) and a finding on body content.
- **Fixed heights kill scaling**: hardcoded `frame(height:)` on text containers clips at large sizes — flag them; prefer minimums.
- **Icons scale too**: SF Symbols pick up Dynamic Type when paired with text styles (`imageScale`, `font` on `Image`); fixed-size custom icons next to scaling text look broken at AX sizes.

## Color-independence

- **State never rides on color alone**: error/success/warning need an icon, text, or shape change alongside the color. Red-vs-green status dots are the canonical finding (8% of men can't tell).
- **`\.accessibilityDifferentiateWithoutColor`** — honor it where the design is color-coded by nature (charts, category tags): add patterns, shapes, or labels when it's on.
- Charts: prefer direct labeling / patterns over legend-by-color; Swift Charts' `chartForegroundStyleScale` supports symbol+color pairing.

## Motion

- **Every animation checks Reduce Motion**: `@Environment(\.accessibilityReduceMotion)` → `withAnimation(reduceMotion ? nil : .default)`. Grep for bare `withAnimation` / `UIView animateWithDuration:` in files that never read the setting.
- **What must reduce**: parallax, large translations, auto-playing carousels, shimmer/typing indicators, anything looping. Subtle opacity/color fades may stay.
- **Cross-fade is the universal fallback** — replace movement with fades, don't just delete feedback.
- `\.accessibilityPlayAnimatedImages` gates auto-playing animated images (iOS 17+).

## Smart Invert & appearance edge cases

- Photos, avatars, media previews, brand marks: `.accessibilityIgnoresInvertColors()` / `accessibilityIgnoresInvertColors = YES` — otherwise Smart Invert renders them as negatives.
- Verify custom `.colorScheme`/`.preferredColorScheme` overrides don't lock a screen out of the user's chosen appearance without reason.

## Audit sequence

1. Per screen, per theme: run the contrast calculator on body text, secondary text, and essential icons; list < 4.5:1 / < 3:1 hits.
2. Grep for `system(size:)` / `systemFontOfSize:` / fixed text-container heights / `dynamicTypeSize(...)` caps.
3. List every color-conveyed state; check each for a non-color channel.
4. Grep animations for missing Reduce Motion checks.
