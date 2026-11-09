# Iconography audit

Icons fail silently: a misspelled or too-new symbol renders nothing, a frame-sized symbol ignores Dynamic Type, an icon-only button announces "button." Audit by what the user receives, not by how the code looks.

## The symbol facade

- **Is there one?** Count `Image(systemName: "` / `Label(_, systemImage: "` / `UIImage(systemName: "` call sites. More than a handful outside the design-system module → recommend an `AppIcon` enum (see `bootstrap.md`) and migrate call sites screen by screen.
- **Cases named by meaning** (`.delete`, not `.trash`). Flag facades that just mirror glyph names — they don't survive a glyph swap.
- **Availability test exists**: a parameterized test over `AppIcon.allCases` asserting `UIImage(systemName:) != nil` (macOS: `NSImage(systemSymbolName:accessibilityDescription:)`), run on the minimum-deployment simulator. Without it, a symbol newer than the deployment target ships blank on older OS versions.
- **Fallbacks live in the facade** (`if #available` inside a computed `systemName`), not scattered at call sites.
- **Directional names**: flag `chevron.right` / `arrow.left` used for navigation — use `.forward` / `.backward` so they mirror in RTL.

## Sizing and alignment

- **Findings**: `.resizable()` + `.frame(width:height:)` on a symbol; `.font(.system(size: N))` on a symbol; `UIImage.SymbolConfiguration(pointSize:)` with a fixed size for text-adjacent icons.
- **Fixes**: `.font(textStyle)`, `.imageScale(.small/.medium/.large)`, `.fontWeight(_:)`; UIKit: `UIImage.SymbolConfiguration(textStyle: .body)` + `adjustsImageSizeForAccessibilityContentSizeCategory = true`.
- **Fixed slots** (list-row leading tiles, avatars with badges) → `@ScaledMetric(relativeTo:)` so the slot scales.
- **Hit targets**: icon-only controls ≥ 44×44pt; check with the Accessibility Inspector's audit.

## Rendering

- **Mode chosen per context and applied in a style**, not ad hoc: toolbars and tinted controls usually `.hierarchical`; status glyphs that carry intrinsic color (weather, battery) `.multicolor`; branded two-tone `.palette` with token colors.
- **Variants**: flag `"heart.fill"` hardcoded where `.symbolVariant(.fill)` driven by state would do; flag pre-filled tab bar icons (the system fills selected tab items on iOS).
- **Variable values** for levels (signal, volume, progress) instead of glyph swapping.
- **Colors from tokens** (`.foregroundStyle(.tint)`, semantic colors). Check every icon in Dark Mode and Increase Contrast — gray-on-gray secondary icons are a common contrast miss (non-text contrast target is 3:1).

## Symbol effects

- Built-in effects over hand-rolled `rotationEffect` / `scaleEffect` loops for icon animation.
- `.contentTransition(.symbolEffect(.replace))` for state swaps (play/pause, follow/following).
- **Indefinite effects** (`.pulse`, `.variableColor`, `.rotate`, `.breathe`) must stop when the state ends and be gated on `accessibilityReduceMotion`.
- Don't animate on every appearance of a list row — effects belong to user actions and state changes.

## Custom symbols

- Custom glyphs as **Symbol Image Sets** in an asset catalog (from an SF Symbols template), not PNG/PDF image sets — otherwise they don't scale with text, take weights, or support rendering modes.
- Annotated layers if the app uses hierarchical/palette rendering or effects on them.
- Loaded with `bundle: .module` inside a package; exposed through the facade.
- Weight/scale variants present (at least the template's Regular plus small/medium/large) — a custom symbol that only has one weight looks wrong next to `.semibold` text.

## Icon accessibility

| Situation | Expected |
|---|---|
| Icon + text saying the same thing | `Label`, or icon `.accessibilityHidden(true)` |
| Icon-only button | `Label(title, icon:)` + `.labelStyle(.iconOnly)`, or `.accessibilityLabel` from the strings facade |
| Standalone meaningful image | `.accessibilityLabel` (localized) |
| Purely decorative | `.accessibilityHidden(true)` / `Image(decorative:)` |
| State shown by icon (favorited) | Variant change **and** `.accessibilityValue` / `.isSelected` trait |

- Hardcoded English labels → route through the strings facade.
- Emoji used as icons → replace with symbols.

## App icon

- **Format**: an Icon Composer `.icon` file set as the target's app icon (Xcode 26+), or a legacy `AppIcon.appiconset`. Recommend migrating legacy icons when the icon is next touched.
- **Layers**: foreground artwork separated from background so the system can render depth; flat full-bleed artwork, no baked mask/shadow/gloss/border.
- **Appearances**: Default, Dark, Clear, and Tinted each reviewed in Icon Composer's preview; a logo that depends on one brand hue can vanish when tinted — adjust per appearance.
- **Legacy catalogs**: 1024pt marketing image opaque (alpha fails upload); no missing required sizes for the deployment targets.
- **Alternate icons**: compiled into the bundle (Alternate App Icon Sets / Include All App Icon Assets build settings) and exercised via `setAlternateIconName` on device; each alternate has every appearance too.
- **Content**: no SF Symbols, no Apple hardware imagery, no text that becomes illegible at small sizes.
- **Consistency**: the App Store marketing icon and the in-app icon are the same artwork; watchOS/macOS shapes previewed rather than assumed.

## Audit sequence

1. Count raw symbol strings and fixed-size symbols (see `bootstrap.md` searches).
2. Locate or design the facade; check for the availability test.
3. Sweep icon-only controls for labels.
4. Check rendering mode/variant consistency on the main navigation surfaces (toolbars, tab bar, list rows).
5. Review the app icon source and every appearance.
