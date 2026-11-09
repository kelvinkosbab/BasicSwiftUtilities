---
description: Apple design system and core UI components — a DesignSystem module with semantic color, type, spacing, and shape tokens; Dynamic Type-safe custom fonts; component styles (ButtonStyle/LabelStyle) over wrapper views; Liquid Glass adoption; environment theming; previews and a component gallery
globs: "**/*.swift"
paths:
  - "**/*.swift"
must:
  - "Features use role-named design tokens, never literal colors, fonts, or spacing."
  - "Custom fonts scale with Dynamic Type (`relativeTo:`); text styles are the type scale."
  - "Prefer styles (`ButtonStyle`, `LabelStyle`) over wrapper views, and system components first."
  - "Standard components adopt Liquid Glass for free; remove custom bar backgrounds and use glass only for floating controls."
---

# Apple Design System & Core UI Components

An app without a design system accretes `Color(red:green:blue:)`, `.font(.system(size: 15))`, `.padding(13)`, and six slightly different primary buttons — each one a Dark Mode, Dynamic Type, or Increase Contrast bug waiting for a user to find it. A design system here is small and boring: **tokens** (color, type, spacing, shape), the **icon facade** (see [`apple-iconography.md`](./apple-iconography.md)), and a handful of **component styles**, in one module that every feature imports. To scaffold one or audit an existing app against it, invoke the **`swift-design-system-pro`** skill.

## Where It Lives

- **One `DesignSystem` (or `UI`) module** in the local package (see [`apple-modular-architecture.md`](./apple-modular-architecture.md)): tokens, icons, styles, shared components, previews. It depends on `Core` at most — **never on feature modules or models**. Features depend on it.
- **Components take data and closures, not view models.** `PrimaryButton(title:action:)`, never `PrimaryButton(viewModel:)`. A design-system type that imports a feature's domain model is in the wrong module.
- **Resources load via `Bundle.module`** — asset-catalog colors, custom fonts, custom symbols. `Bundle.main` works in the app target and breaks the moment the code moves into the module.

## Tokens — Semantic, Not Literal

### Color

- **Name colors by role** (`textPrimary`, `surface`, `surfaceElevated`, `accent`, `destructive`, `separator`), never by hue (`blue500`). Hue names leak into call sites and make dark mode and rebrands painful.
- **Start from system semantic colors** (`.primary`, `.secondary`, `Color(.systemBackground)`, `.tint`) — they already adapt to Dark Mode, Increase Contrast, and vibrancy. Add brand colors only where the system has no equivalent.
- **Brand colors are asset-catalog color sets** with Any / Dark and **High Contrast** variants; expose them via generated symbols or a token namespace:

  ```swift
  public extension ShapeStyle where Self == Color {
      static var surfaceElevated: Color { Color("surfaceElevated", bundle: .module) }
      static var accentBrand: Color { Color("accentBrand", bundle: .module) }
  }
  // Call site: .foregroundStyle(.accentBrand) — no literals, no hex.
  ```

- **Set the app tint once** (`.tint(.accentBrand)` at the root, or the asset catalog's AccentColor) — don't re-tint individual controls.
- **No `Color(red:green:blue:)`, hex initializers, or `UIColor(white:)` in feature code.** Literal colors don't adapt to appearance or contrast settings. Contrast targets (4.5:1 body, 3:1 large text) are set in [`apple-accessibility-best-practices.md`](./apple-accessibility-best-practices.md) — check every token pair in both appearances.

### Typography

- **Text styles are the type scale.** `.largeTitle` … `.caption2` map to Dynamic Type; use them directly or wrap them in role-named tokens (`.font(.cardTitle)`) that resolve to a text style.
- **Custom fonts must stay dynamic:** `Font.custom("Brand-Semibold", size: 17, relativeTo: .headline)` — never `Font.custom(_:fixedSize:)` or `.system(size:)` for user-visible text. Register packaged fonts from `Bundle.module` once at launch (`CTFontManagerRegisterFontsForURL`), since a package can't add `UIAppFonts` entries.
- **Weight and design** via modifiers (`.fontWeight(.semibold)`, `.fontDesign(.rounded)`, `.monospacedDigit()` for changing numbers) rather than more font files.
- **Test at the largest accessibility size** (AX5): layouts must reflow (`ViewThatFits`, or HStack → VStack via `dynamicTypeSize.isAccessibilitySize`), not truncate.

### Spacing, Size, Shape

- **A small spacing scale** (`Spacing.xs = 4 … xl = 32`) as `CGFloat` constants. Pick from the scale; a `13` in a view is a finding.
- **Spacing that sits next to text scales with it** — `@ScaledMetric(relativeTo: .body) private var rowSpacing = Spacing.m`.
- **Corners follow their container** — `ConcentricRectangle()` / `.containerShape(_:)` so nested rounded shapes stay concentric with the device and window corners on iOS 26+. A hardcoded `cornerRadius: 12` inside a sheet looks wrong next to the system's.
- **Minimum hit target 44×44pt** for every control, regardless of glyph size. On macOS the touch target is **36×36pt** with the control's size unchanged — see [`apple-mac-touch.md`](./apple-mac-touch.md).

### Motion

- **Motion tokens live here too** — a role-named `Motion` namespace (`feedback`, `standard`, `enter`, `exit`) instead of durations and curves at call sites. See [`apple-motion-design.md`](./apple-motion-design.md).

## Liquid Glass (iOS 26+ SDKs)

- **Standard components adopt it for free** when built with the current SDK — navigation bars, toolbars, tab bars, sheets, menus, and system button styles. **Remove custom bar backgrounds and blur hacks**; they fight the material.
- **Glass is for the control layer floating above content** (toolbars, floating actions, overlays) — not for content itself. Don't put glass on list rows, cards, or text blocks.
- **Custom floating controls:** `.glassEffect()` (optionally `.glassEffect(.regular.interactive(), in: .capsule)`), grouped in a `GlassEffectContainer` so neighboring glass shapes blend and morph; use `.buttonStyle(.glass)` / `.glassProminent` for buttons.
- **Don't stack glass on glass** and keep text on glass legible — let the system's vibrancy handle foreground color rather than forcing literals.
- **Respect Reduce Transparency / Increase Contrast** — standard components do; custom effects must be checked with those settings on.
- The `UIDesignRequiresCompatibility` Info.plist opt-out is temporary and slated for removal — treat it as migration time, not a decision.

## Components — Styles Before Wrappers

- **Customize system controls with styles**, which keep semantics, accessibility, keyboard focus, and platform adaptation intact:

  ```swift
  public struct PrimaryButtonStyle: ButtonStyle {
      @Environment(\.isEnabled) private var isEnabled

      public func makeBody(configuration: Configuration) -> some View {
          configuration.label
              .font(.headline)
              .frame(maxWidth: .infinity, minHeight: 44)
              .padding(.horizontal, Spacing.m)
              .foregroundStyle(.white)
              .background(Color.accentBrand.opacity(isEnabled ? 1 : 0.4), in: .capsule)
              .opacity(configuration.isPressed ? 0.8 : 1)
      }
  }

  public extension ButtonStyle where Self == PrimaryButtonStyle {
      static var primary: PrimaryButtonStyle { .init() }
  }
  // Call site: Button(Strings.Checkout.pay, action: pay).buttonStyle(.primary)
  ```

- **Same pattern for** `LabelStyle`, `ToggleStyle`, `ProgressViewStyle`, `GroupBoxStyle`, `TextFieldStyle`, `MenuStyle`. Prefer the built-ins (`.borderedProminent`, `.bordered`, `.glass`) when they're close enough — every custom style is surface you maintain across OS releases.
- **Wrapper views only for genuinely composite components** (a card with header/body/footer slots, a rating row). Before writing one, check the system: `ContentUnavailableView` (empty/error states), `LabeledContent`, `Gauge`, `ShareLink`, `PhotosPicker`.
- **Composite components take `@ViewBuilder` slots**, not twenty configuration parameters. Expose a style protocol of your own only when two real variants exist.
- **Components are stateless where possible** — state hoisted to the caller; no network or persistence calls inside. They must be previewable with literal data.
- **Every component ships accessibility** — labels pass through, compound content merges (`.accessibilityElement(children: .combine)`), headers carry `.isHeader`. Building it once in the component fixes it everywhere.

## Theming via Environment

- **Per-subtree variation** (a branded onboarding flow, a compact density) goes through custom environment values, not globals or singletons:

  ```swift
  public enum Density: Sendable { case regular, compact }
  public extension EnvironmentValues {
      @Entry var density: Density = .regular
  }
  ```

- **Respect system appearance.** Don't force `.preferredColorScheme(.light)` app-wide to dodge dark-mode work; offer an in-app override only as a user setting.
- **No global mutable theme state** (`static var currentTheme`) — it violates strict concurrency and can't vary per window. See [`apple-swift6-strict-concurrency.md`](./apple-swift6-strict-concurrency.md).

## Previews & the Component Gallery

- **Every component has `#Preview`s covering its states** — default, disabled, loading, error, long localized text, Dark Mode, and the largest Dynamic Type size (`.environment(\.dynamicTypeSize, .accessibility5)`).
- **A gallery screen** (debug-only, or a `DesignSystemCatalog` preview) renders every token and component in one place — the fastest way to review a rebrand or a new OS release.
- **Snapshot tests are optional** but cheap for components; if used, snapshot light/dark × default/AX5 and keep them out of the unit-test hot path (see [`apple-testing-strategy.md`](./apple-testing-strategy.md)).

## Adopting in an Existing App

1. **Create the module** and move color/font/spacing literals into tokens as you touch files — don't stop the world.
2. **Inventory duplicates** (primary buttons, cards, empty states); converge each on one style or component, one screen at a time.
3. **Swap literals for tokens** with search: `Color(red:`, `.font(.system(size:`, `cornerRadius:`, `systemName: "`. Each hit is a migration candidate.
4. **Remove custom bar backgrounds** when moving to the current SDK so Liquid Glass applies.
5. Keep the gallery green: every new component lands with previews.

## Common Pitfalls

- **Literal colors, sizes, and fonts in feature views** — the root cause of most Dark Mode and Dynamic Type bugs.
- **Hue-named tokens** (`blue500`) at call sites — defeats theming.
- **`Font.custom(_:size:)` without `relativeTo:`** — a custom font frozen at one size.
- **Wrapper `PrimaryButton` view that re-implements `Button`** — loses keyboard focus, accessibility traits, and platform styling. Write a `ButtonStyle`.
- **Design-system module importing feature models** — an inverted dependency; components take primitives and closures.
- **Glass on content, or custom blurs behind standard bars** — fights Liquid Glass.
- **Forcing light mode app-wide.**
- **Components with no previews** — states nobody has looked at ship broken.
