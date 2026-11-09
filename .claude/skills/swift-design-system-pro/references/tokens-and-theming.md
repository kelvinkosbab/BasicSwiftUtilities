# Tokens and theming audit

Tokens exist so the answer to "what color is secondary text?" lives in one place and adapts to every appearance automatically. Audit whether that's true.

## Color

**What good looks like**

- A role-named palette: `textPrimary`, `textSecondary`, `surface`, `surfaceElevated`, `accent`, `destructive`, `success`, `separator`, `overlay`.
- Built on system semantic colors where they exist (`.primary`, `.secondary`, `Color(.systemBackground)`, `Color(.secondarySystemBackground)`, `Color(.separator)`, `.tint`); brand colors only where the system has none.
- Brand colors as asset-catalog color sets with **Any / Dark** and **High Contrast** variants, in the design-system module's catalog, loaded with `bundle: .module` (or via generated `ColorResource` symbols).
- One app tint set at the root or via AccentColor.

**Findings**

- `Color(red:green:blue:)`, hex initializers, `Color(white:)`, `UIColor(red:…)` outside the token file — broken in at least one appearance.
- Hue-named tokens at call sites (`.blue500`) — a rebrand touches every file.
- Tokens with no Dark or High Contrast variant.
- Text/background token pairs that fail 4.5:1 (body) / 3:1 (large text, icons) in either appearance. Verify with Accessibility Inspector's contrast calculator, not by eye.
- `.preferredColorScheme(.light)` applied app-wide to avoid dark-mode work.
- `.opacity()` stacked on semantic colors to make "lighter" variants — opacity changes contrast unpredictably over different backgrounds; define a token instead.

## Typography

**What good looks like**

- Text styles as the scale (`.largeTitle` … `.caption2`), optionally wrapped in role names (`Font.cardTitle` → `.headline`).
- Custom brand fonts via `Font.custom(_:size:relativeTo:)` with the closest text style; registered once from `Bundle.module` at launch (`CTFontManagerRegisterFontsForURL`) since packages can't declare `UIAppFonts`.
- `.monospacedDigit()` on changing numbers (timers, prices, counters) so layout doesn't jitter.

**Findings**

- `.font(.system(size:))` / `Font.custom(_:fixedSize:)` / `Font.custom(_:size:)` without `relativeTo:` for user-visible text.
- UIKit labels without `adjustsFontForContentSizeCategory = true`, or `UIFont(name:size:)` not passed through `UIFontMetrics(forTextStyle:).scaledFont(for:)`.
- `.lineLimit(1)` on primary content without a large-text alternative layout.
- Truncated or overlapping controls at AX5 — check the 3–5 most-used screens with `.environment(\.dynamicTypeSize, .accessibility5)` previews.

## Spacing, sizing, shape

- **Scale**: a `Spacing` namespace (4/8/12/16/24/32 or similar). Off-scale literals (`.padding(13)`, `spacing: 7`) are inconsistency findings; batch them per screen, don't report each.
- **Text-relative spacing** via `@ScaledMetric(relativeTo:)`.
- **Corner radius**: on iOS 26+ SDKs prefer `ConcentricRectangle()` / `.containerShape(_:)` so nested shapes match the container and device corners; flag hardcoded radii on views nested inside sheets, cards, or glass containers. Keep a small radius scale for the rest.
- **Minimum hit target** 44×44pt for controls.

## Liquid Glass adoption (iOS 26+ SDKs)

- **Free adoption blocked?** Custom `UINavigationBarAppearance` backgrounds, `.toolbarBackground(.visible)` with opaque colors, `.background(.ultraThinMaterial)` behind bars, or custom tab bars — each prevents the system material. Recommend removing and re-checking.
- **Glass on content** (list rows, cards, text) — flag; glass belongs to the floating control layer.
- **Custom glass**: `.glassEffect(…)` shapes grouped in a `GlassEffectContainer`; `.glassEffectID(_:in:)` for morphing transitions; `.buttonStyle(.glass)` / `.glassProminent` instead of hand-built translucent buttons.
- **Glass on glass**, or literal foreground colors over glass that defeat vibrancy.
- **Settings check**: Reduce Transparency and Increase Contrast on — custom effects must stay legible.
- **`UIDesignRequiresCompatibility`** present → note it's a temporary opt-out slated for removal and add the migration to the plan.

## Environment theming

- Per-subtree variation (density, branded flow, prominence) through `@Entry` environment values — not singletons, not `static var` (strict-concurrency violation), not prop-drilling a theme struct through every initializer.
- Components read the environment; features set it at the subtree root.
- Multi-window apps (iPad, Mac, iPhone Duo) can show different subtrees side by side — global theme state is wrong there by construction.

## UIKit interop

- Shared tokens exposed to UIKit as `UIColor(named:in:compatibleWith:)` / `UIColor(Color)` and `UIFontMetrics`-scaled fonts — one source, two frameworks.
- `traitCollection` changes (appearance, contrast, size category) handled via `registerForTraitChanges` (iOS 17+), not cached `CGColor`s that go stale on appearance change.

## Audit sequence

1. Count literal colors, fixed fonts, off-scale spacing, hardcoded radii.
2. Locate the token definitions (if any); check variants and contrast pairs.
3. Preview the top screens in Dark, Increase Contrast, AX5, and RTL.
4. Check bars/toolbars/tab bars for anything blocking Liquid Glass.
5. Check theming mechanism for global mutable state.
