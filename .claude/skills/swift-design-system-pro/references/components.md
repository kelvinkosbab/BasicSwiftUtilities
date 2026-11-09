# Components audit

The goal is fewer, better components: each pattern implemented once, adapting everywhere, accessible by construction.

## Styles vs wrapper views

| Need | Use | Avoid |
|---|---|---|
| Branded button look | `ButtonStyle` (+ `static var` on `ButtonStyle where Self ==`) | `struct PrimaryButton: View { … onTapGesture … }` |
| Custom press/long-press behavior | `PrimitiveButtonStyle` | gesture recognizers on a plain view |
| Icon + title layout | `LabelStyle` | `HStack { Image; Text }` re-built per screen |
| Toggle look | `ToggleStyle` | `Button` that flips a Bool |
| Text field chrome | `TextFieldStyle` / modifiers | wrapper that hides `TextField` configuration |
| Grouped container | `GroupBoxStyle` or a slot-based `Card` | five ad-hoc `RoundedRectangle` backgrounds |
| Empty / error state | `ContentUnavailableView` | custom empty-state views per screen |
| Key-value row | `LabeledContent` | `HStack { Text; Spacer; Text }` |

- A wrapper view that re-creates a control (`onTapGesture` on a styled `Text`) is **broken**, not just inconsistent: it loses button traits, keyboard focus, the disabled state, Switch Control activation, and pointer hover. Report it at the broken tier.
- Styles read `@Environment(\.isEnabled)`, `configuration.isPressed`, `controlSize`, and `dynamicTypeSize` — flag styles that ignore the disabled state.
- Prefer built-in styles (`.borderedProminent`, `.bordered`, `.borderless`, `.glass`, `.glassProminent`) and only tint/shape them; a custom style is justified when the brand genuinely differs.

## The core component set

A new app needs roughly this, mostly as styles and thin composites — scaffold these and stop:

- Buttons: primary, secondary, destructive, icon-only (styles over `Button`).
- Text input: field chrome + inline validation message.
- Containers: card (slots: header/content/footer), section header (`.isHeader`).
- Rows: a list row with leading icon slot, title/subtitle, trailing accessory — using `Label`/`LabeledContent` underneath.
- Feedback: loading (`ProgressView` styled), empty/error (`ContentUnavailableView` with actions), inline banner.
- Badge/tag/chip if the product uses them.

Add a component when the pattern appears a **third** time; flag speculative components no screen uses.

## Duplicate inventory

- Search for button-like constructs: custom `ButtonStyle` conformances, views named `*Button`, `.onTapGesture` on `Text`/`HStack`. Group by visual role; more than one per role is an inconsistency finding with a convergence recommendation (keep the most accessible implementation, migrate callers).
- Same for cards, empty states, headers, and loading indicators.

## API shape

- **Data and closures in, no view models**: `Card(title:action:)`, not `Card(viewModel:)`.
- **`@ViewBuilder` slots** for content that varies, instead of growing boolean/optional parameters (`showsBadge`, `badgeCount`, `subtitle2`).
- **Localized inputs** as `LocalizedStringResource` / `Text`, never `String` that callers fill with English literals.
- **Stateless where possible**; internal `@State` only for purely visual state (pressed, expanded animation).
- **No side effects** — no networking, persistence, analytics, or haptics decisions inside design-system components; expose callbacks.
- **Public API documented** per `apple-documentation-strategy.md` — the design system is a library other modules consume.

## Accessibility baked in

- Compound components merge (`.accessibilityElement(children: .combine)`) and keep a sensible reading order.
- Section headers carry `.isHeader`; selected states expose `.isSelected`.
- Context menus on components mirror into `.accessibilityActions`.
- Hit targets ≥ 44pt; focus works under Full Keyboard Access (`.focusable()` only where a non-standard control truly needs it).
- Motion inside components respects Reduce Motion.

## Previews, gallery, tests

- Every public component: `#Preview`s for default, disabled, loading/error where applicable, long localized text (a German/pseudolanguage string), Dark Mode, AX5, and RTL (`.environment(\.layoutDirection, .rightToLeft)`).
- A gallery (debug screen or catalog preview) listing every token and component. Flag a design system without one — reviewers can't see the whole surface.
- Snapshot tests (e.g., swift-snapshot-testing) are worth it for components: light/dark × default/AX5. Keep them in a separate test target or plan so they don't slow unit tests; record on a pinned simulator/OS.
- Unit-test token resolution logic only if there is logic (e.g., density mapping); don't test that a color equals itself.

## Audit sequence

1. Inventory component-like types and duplicates per role.
2. Check each for style-vs-wrapper correctness and accessibility.
3. Check API shape (view-model inputs, `String` text, missing slots).
4. Check previews/gallery coverage.
5. Propose convergence order: broken implementations first, then the most-used duplicates.
