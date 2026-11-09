---
description: Apple iconography — SF Symbols (typed facade, rendering modes, variants, symbol effects, availability), custom symbols in asset catalogs, icon sizing via font, icon accessibility, and app icons built with Icon Composer (layered Liquid Glass icons, dark/tinted/clear variants)
globs: "**/*.swift"
paths:
  - "**/*.swift"
must:
  - "Use a typed `AppIcon` facade; no raw `systemName:` strings in features."
  - "Size symbols with fonts or `imageScale`, never `.resizable().frame(...)`; keep 44pt hit targets."
  - "Icon-only buttons keep a `Label` with `.labelStyle(.iconOnly)`; decorative icons are hidden."
  - "App icons come from Icon Composer, with no baked mask or shadow."
---

# Apple Iconography

Icons are UI, not decoration: they carry meaning, they must scale with Dynamic Type, they must read in light, dark, tinted, and Increase Contrast, and they must say something to VoiceOver (or deliberately say nothing). Most icon bugs in shipping apps are the same handful — raw symbol strings that silently render nothing, frame-sized symbols that ignore Dynamic Type, icon-only buttons with no label, and app icons with baked-in shapes. This rule pins the conventions; for a full audit or to scaffold an icon system, invoke the **`swift-design-system-pro`** skill.

## SF Symbols First

- **Default to SF Symbols** for UI glyphs. They match San Francisco's weights, align to text baselines, scale with Dynamic Type, support rendering modes and animation, and localize (some symbols have RTL and script-specific variants the system picks automatically).
- **Custom artwork only when no symbol fits** — brand marks, domain-specific objects. Make those **custom symbols** (below), not PNGs, so they behave like everything else.
- **Licensing:** SF Symbols may not be used in app icons, logos, or other trademark-related use. A symbol is fine *inside* the app; it is never your app icon.

## A Typed Icon Facade — No Raw Symbol Strings

`Image(systemName: "chevron.rigth")` compiles and renders **nothing** — `UIImage(systemName:)` returns `nil`, SwiftUI draws an empty view, and no test fails. Treat symbol names like localization keys: one typed facade, no string literals at call sites.

```swift
/// The app's icon vocabulary. Name by *meaning*, not by glyph.
public enum AppIcon: String, CaseIterable, Sendable {
    case settings = "gearshape"
    case delete = "trash"
    case share = "square.and.arrow.up"
    case favorite = "heart"
    case disclosure = "chevron.forward"   // .forward, not .right — mirrors in RTL
}

public extension Image {
    init(_ icon: AppIcon) { self.init(systemName: icon.rawValue) }
}

public extension Label where Title == Text, Icon == Image {
    init(_ title: LocalizedStringResource, icon: AppIcon) {
        self.init { Text(title) } icon: { Image(icon) }
    }
}
```

- **Name cases by meaning** (`.delete`, `.favorite`) so a glyph swap is a one-line change and a reviewer can tell intent from call sites.
- **`CaseIterable`** enables a one-line test that every case resolves: `#expect(UIImage(systemName: icon.rawValue) != nil)` (or `NSImage(systemSymbolName:accessibilityDescription:)` on macOS) — run it on your *minimum* deployment target's simulator, where newer symbols are missing.
- **Symbols have availability.** Each symbol ships in a specific SF Symbols release tied to an OS version; check it in the SF Symbols app's info panel. When the minimum target predates a symbol, provide a fallback in the facade, not at the call site.
- **Prefer directional-neutral names** (`chevron.forward`, `arrow.backward`) over `.right` / `.left` so the glyph mirrors under RTL.
- The facade lives in the design-system module (see [`apple-design-system.md`](./apple-design-system.md)), next to colors and type.

## Sizing — Use Font, Not Frame

```swift
// ✅ Scales with Dynamic Type, matches adjacent text weight and baseline
Image(.settings).font(.title3)
Label(Strings.Settings.title, icon: .settings).font(.body)
Image(.settings).imageScale(.large)          // small / medium / large relative to the font

// ❌ Frozen at 24pt for every user; weight no longer matches text
Image(systemName: "gearshape").resizable().frame(width: 24, height: 24)
```

- **Symbols size through the font** (`.font(.title3)`, `.imageScale(_:)`, `.fontWeight(_:)`). `.resizable().frame(...)` on a symbol defeats Dynamic Type, breaks baseline alignment, and stretches stroke weights.
- **Fixed-size icon slots** (a 28pt tile in a list row) → `@ScaledMetric(relativeTo: .body) private var tile = 28.0` so the slot still grows with text.
- **Hit targets stay ≥ 44×44pt** even when the glyph is small — pad the button, not the image.

## Rendering Modes, Variants, Variable Values

- **Rendering mode** — `.symbolRenderingMode(_:)`: `.monochrome` (one color), `.hierarchical` (one color, layered opacity — a good default for tinted UI), `.palette` (explicit colors per layer via `.foregroundStyle(a, b, c)`), `.multicolor` (the symbol's intrinsic colors). Pick per *context*, set it once in a style, not per call site.
- **Variants** — `.symbolVariant(.fill)` / `.circle` / `.slash` instead of hardcoding `"heart.fill"` in the facade. Containers apply variants for you: `TabView` items render `.fill` automatically on iOS, so don't pre-fill tab icons.
- **Variable values** — `Image(systemName: "wifi", variableValue: strength)` for symbols that encode a level (signal, volume, progress). Don't fake levels by swapping three different glyphs.
- **Colors come from the theme** — `.foregroundStyle(.tint)` / semantic colors, never hardcoded RGB in a view. Check the symbol in light, dark, and Increase Contrast.

## Symbol Effects (Animation)

- Use the built-in effects — `.symbolEffect(.bounce, value: count)` for discrete feedback, `.contentTransition(.symbolEffect(.replace))` when swapping glyphs (play ↔ pause), `.symbolEffect(.pulse)` / `.variableColor` for ongoing activity — rather than hand-rolled scale/rotation animations.
- **Animate meaning, not decoration.** An effect should confirm an action or signal state. Indefinite effects (pulse, variable color, rotate) cost attention and battery — stop them when the state ends.
- **Honor Reduce Motion** for indefinite or decorative effects: `@Environment(\.accessibilityReduceMotion)` → `.symbolEffect(.pulse, isActive: isActive && !reduceMotion)`. See [`apple-accessibility-best-practices.md`](./apple-accessibility-best-practices.md).

## Custom Symbols

- **Author from a template.** In the SF Symbols app, export a template for the closest existing symbol, draw in a vector tool on its guides (so weights and margins line up), then import the `.svg` into an asset catalog as a **Symbol Image Set**. Annotate layers in the SF Symbols app if the symbol needs hierarchical/palette rendering or animation.
- **Load by asset name** through the same facade, so call sites can't tell custom from system:

  ```swift
  public extension Image {
      // Custom symbols live in the design-system module's asset catalog.
      static var brandMark: Image { Image("brand.mark", bundle: .module) }
  }
  ```

- **In a Swift package, always `bundle: .module`** — `Image("brand.mark")` looks in `Bundle.main` and renders nothing from a module. (Same trap as every other packaged resource — see [`apple-modular-architecture.md`](./apple-modular-architecture.md).)
- Prefer Xcode's **generated asset symbols** (`Image(.brandPhoto)`, `Color(.brandAccent)`) for non-symbol asset-catalog images and colors — a typo is a compile error.
- **Raster artwork** (illustrations, photos) goes in the asset catalog with appearance variants (Any / Dark / high-contrast) — never ship separate `@2x/@3x` PNGs loose in the bundle. Prefer PDF/SVG with "Preserve Vector Data" for flat illustrations.

## Icon Accessibility

- **Decorative** (an icon beside text that already says the same thing): `.accessibilityHidden(true)` — or use `Label`, which exposes only its title to VoiceOver.
- **Icon-only controls** keep their label: `Button { … } label: { Label(Strings.Actions.delete, icon: .delete) }.labelStyle(.iconOnly)`. Never `Button { … } label: { Image(.delete) }` with no text — VoiceOver falls back to a symbol-name guess ("trash") or nothing.
- **Meaningful standalone images** get `.accessibilityLabel(...)` from the strings facade (see [`apple-localization-best-practices.md`](./apple-localization-best-practices.md)).
- **State is never icon-color alone** — `.fill` vs outline *and* a label/value change; honor `accessibilityDifferentiateWithoutColor`.
- **No emoji as icons** in labels or buttons — they read inconsistently in VoiceOver and render as noise on braille displays.

## App Icons — Icon Composer

- **Build the app icon in Icon Composer** (ships with Xcode 26+) as a layered `.icon` file: separate foreground layers over a background, so the system can render **Liquid Glass** depth and produce the **Default, Dark, Clear, and Tinted** appearances from one source. Add the `.icon` file to the app target and select it as the app icon.
- **Supply flat, full-bleed artwork.** Don't bake in the rounded-rect mask, drop shadows, gloss, or a border — the system applies shape and glass. Baked effects double up and look wrong in Clear/Tinted modes.
- **Design every appearance on purpose.** Check Dark and Tinted in Icon Composer's previews; a logo that relies on a single brand color can vanish when tinted.
- **One source across platforms** — the same `.icon` drives iOS, iPadOS, macOS, and watchOS shapes; check each platform's preview rather than assuming.
- **Legacy asset-catalog icons** (`AppIcon.appiconset`) still build; migrate when you next touch the icon. The 1024pt marketing image must be opaque (no alpha) or App Store upload fails.
- **Alternate icons** (`UIApplication.shared.setAlternateIconName(_:)`) must be compiled into the bundle — list them in the target's *Alternate App Icon Sets* build setting (or enable *Include All App Icon Assets*) and verify on device.
- Never use SF Symbols, screenshots, or photos of Apple hardware in the app icon (App Review).

## Common Pitfalls

- **Raw `systemName:` strings at call sites** — a typo or a too-new symbol renders nothing, silently. Use the facade.
- **`.resizable().frame(...)` on a symbol** — kills Dynamic Type and weight matching.
- **`Image("name")` for a packaged asset** — missing `bundle: .module`; works in the app target, blank in a module.
- **Icon-only buttons with no label** — VoiceOver users get "button" or a glyph name.
- **`.right` / `.left` glyph names for navigation** — don't mirror in RTL. Use `.forward` / `.backward`.
- **Pre-filled tab icons** — fights the system's automatic `.fill` variant.
- **Indefinite symbol effects ignoring Reduce Motion.**
- **App icon with baked mask, shadow, or gloss** — breaks Liquid Glass and Tinted appearances.
- **SF Symbol as the app icon or logo** — licensing violation and App Review risk.
