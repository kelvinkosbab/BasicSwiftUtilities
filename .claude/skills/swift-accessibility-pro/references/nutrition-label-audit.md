# Pass / fail criteria for an Accessibility Nutrition Label audit

> **Sources.** Apple's VoiceOver, Dynamic Type, and Sufficient Contrast accessibility-specialist agent skills in Xcode 27, as published by [Artem Novichkov](https://github.com/artemnovichkov) in [`artemnovichkov/xcode-skills`](https://github.com/artemnovichkov/xcode-skills), with WCAG 2.1 / 2.2 contrast definitions. Rewritten and condensed for this bundle.

The other references find problems; this one gives a **verdict per screen** for the three label features you can mostly judge from source: VoiceOver, Larger Text (Dynamic Type), and Sufficient Contrast. Use it before an App Store Accessibility Nutrition Label claim, or when asked "does this screen pass?". A source pass doesn't replace running the common tasks with the feature on; it tells you what to fix first.

Each screen gets one line per feature: `Verdict: PASS`, `FAIL`, or (contrast only) `NEEDS VERIFICATION`. Don't hedge with "at risk": if the facts are known, commit. Then list passing elements, failing elements (with a fix), recommendations, and the assumptions you made.

## VoiceOver

Fail-eligible criteria:

1. **Missing labels.** Every interactive element and meaningful image has a label. Already labeled: `Button("Save")`, a `Label` inside a button, `Toggle` / `Picker` / `Slider` titles, `TextField` placeholders, a `UIButton` or `NSButton` with a title. Need an explicit label: icon-only or image-only buttons, a `UIButton` with only `setImage`, a meaningful `Image` with no label.
2. **Labels people can't understand when spoken**: file names or URLs (`IMG_2847.heic`), camelCase or snake_case ids (`btnSubmit`), UUIDs or hashes, the element type alone (`"button"`), unexplained abbreviations.
3. **Missing traits on custom interactive views.** Button, Link, Header, and Adjustable are fail-eligible (`.accessibilityAddTraits(.isButton / .isLink / .isHeader)`, `.accessibilityAdjustableAction`; UIKit `accessibilityTraits`; AppKit `setAccessibilityRole`). Selected, StartsMediaSession, SearchField, UpdatesFrequently are recommendations that don't change the verdict. Standard controls already carry their traits.
4. **Meaningful images without labels** (`Image("photo")` neither labeled nor `Image(decorative:)` / `.accessibilityHidden(true)`). When the image name is a variable and intent is unclear, flag it and state the assumption.
5. **UIKit / AppKit interactive views not exposed**: a custom `UIView` with gesture recognizers or touch overrides without `isAccessibilityElement = true`; an `NSView` with mouse overrides without `setAccessibilityElement(true)`.

Exempt: hidden elements, decorative images, disabled controls, standard controls with text, layout containers, system chrome (navigation titles, tab and toolbar labels).

Informational only (report, don't fail): element grouping (`.accessibilityElement(children: .combine)` for rows), custom actions for swipe and long-press affordances, and reading order (`.accessibilitySortPriority`). These matter for the real-task check, so list them.

## Larger Text (Dynamic Type)

- **Pass**: text styles (`.font(.body)`), `UIFont.preferredFont(forTextStyle:)` with `adjustsFontForContentSizeCategory = true`, custom fonts through `UIFontMetrics(forTextStyle:).scaledFont(for:)` or `.custom(_:size:relativeTo:)`, `NSFont.preferredFont(forTextStyle:)`, `@ScaledMetric` dimensions, `ViewThatFits`.
- **Fail**: `.font(.system(size:))`, `.custom(_:size:)` without `relativeTo:`, `UIFont.systemFont(ofSize:)` or `UIFont(name:size:)` without `UIFontMetrics`, AppKit fixed sizes without scaling, a missing `adjustsFontForContentSizeCategory` (scales at launch, never live), `.minimumScaleFactor` as the strategy (shrinks instead of grows), `.lineLimit(1)` on content that can be long, fixed `.frame(height:)` around text.
- **Exempt**: hidden decorative text, bar items that provide the Large Content Viewer (`.accessibilityShowsLargeContentViewer`), system chrome.
- **Informational**: whether horizontal rows switch to vertical at accessibility sizes (`dynamicTypeSize.isAccessibilitySize`, `ViewThatFits`), and whether long content scrolls. Critical at the screen level, not for every subview.

## Sufficient Contrast

1. **Resolve each foreground / background pair** from source: hex or RGB literals, system colors at their documented default values, the nearest ancestor background. Check light and dark appearance.
2. **If a color can't be resolved** (asset-catalog color, runtime theming, a design system you can't see), never guess and never fail it. Mark the element **NEEDS VERIFICATION**, name the color, and say how to check (Accessibility Inspector's color contrast calculator, or the asset's values in both appearances).
3. **Compute** with the WCAG formula: linearize each sRGB channel (`c ≤ 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055)^2.4`), luminance `L = 0.2126 R + 0.7152 G + 0.0722 B`, ratio `(L_lighter + 0.05) / (L_darker + 0.05)`. Composite translucent colors first: `fg × alpha + bg × (1 − alpha)`.
4. **Thresholds**: 4.5:1 for normal text; 3:1 for large text (18pt regular or 14pt bold and up); 3:1 for meaningful UI boundaries and icons; decorative elements exempt.

Screen verdict: **FAIL** if any known pair is below its threshold (a real failure outranks unknowns; report both), **NEEDS VERIFICATION** if nothing fails but some colors are unresolved, **PASS** only if every pair is known and meets its threshold. Show the numbers for each pair so the developer can check the math.
