---
description: Localization conventions for Apple platforms — String Catalogs, type-safe Strings facade, String(localized:), plurals, format args, locale-aware formatters, RTL, translator context.
globs: "**/*.swift"
---

# Apple Localization Best Practices

Every user-facing string is localized. *Including* accessibility labels, error messages, alert bodies, and short pieces of text that "are obviously the same in every language" (they aren't). The cost of localizing from day one is near zero; the cost of retrofitting after the fact is high.

## Source of Truth: String Catalogs

- **Use String Catalogs (`.xcstrings`)** as the project's localization format. Apple-supported since Xcode 15 / iOS 17. Single JSON file, native plurals, native variations (device, length), Xcode UI for translators.
- **One String Catalog per module** (`Localizable.xcstrings` inside the module's resources). Per-module catalogs prevent merge conflicts in monorepos and let modules ship independently.
- **Don't add new entries to legacy `.strings` / `.stringsdict` files.** If they exist, leave them stable but route new strings through the catalog. Migration is per-module, not big-bang.
- **`NSLocalizedString` is permitted only inside the type-safe facade** (see below) — never sprinkled throughout views.

## Type-Safe Strings Facade

Sprinkling `String(localized: "user.profile.title")` across views means a typo becomes a runtime broken string instead of a compile error. Hide all keys behind a single typed enum.

```swift
public enum Strings {
    public enum NavigationTitles {
        public static let home = LocalizedStringResource("home.title")
        public static let nearbyServices = LocalizedStringResource("nearby_services.title")
    }

    public enum Errors {
        public static func portMin(_ minimum: Int) -> LocalizedStringResource {
            LocalizedStringResource("errors.port.min", defaultValue: "Port must be at least \(minimum).")
        }
    }
}
```

- **Use `LocalizedStringResource`** (not raw `String`) — SwiftUI's `Text(_:)` and `.accessibilityLabel(_:)` accept it directly.
- **Format-string helpers are functions**, not interpolation at the call site (so the lookup remains a stable key per string).
- **All UI code uses `Strings.<Section>.<key>`**, never `String(localized:)` directly.
- **The facade module** is the only place that owns localization knowledge — UI modules depend on it.

## SwiftUI Usage

```swift
// Good — Text accepts LocalizedStringResource directly
Text(Strings.NavigationTitles.home)

// Good — error message via the format-function helper
Text(Strings.Errors.portMin(1024))

// Good — explicit String when you actually need a String value
let label = String(localized: Strings.NavigationTitles.home)
view.accessibilityLabel(label)
```

- **Don't use `Text("Home")`** — that's a hardcoded English literal even if it "works" today.
- **Don't pre-format with `String(format:)`** — `LocalizedStringResource` interpolation handles positional args correctly across locales.

## Plurals

```json
"items.count" : {
  "extractionState" : "manual",
  "localizations" : {
    "en" : {
      "variations" : {
        "plural" : {
          "one"   : { "stringUnit" : { "value" : "%d item",  "state" : "translated" } },
          "other" : { "stringUnit" : { "value" : "%d items", "state" : "translated" } }
        }
      }
    }
  }
}
```

- **Always use plural variations**, even for "obvious" English (`%d items`). Russian has 4 plural forms, Polish has 3, Arabic has 6 — your "0 items / 1 item / 2 items" assumption breaks.
- **Lookup via the facade**: `Strings.Items.count(viewModel.itemCount)`. Inside the facade, the `LocalizedStringResource` automatically picks the right variation.
- **Never** stitch plural strings together (`"\(count) " + (count == 1 ? "item" : "items")`).

## Locale-Aware Formatting

Numbers, dates, currencies, and units must format per-locale. **Never** use raw `String(format: "%.2f", value)` or `"\(date)"`.

```swift
// Numbers — respects locale separators (1,234.56 vs 1.234,56)
Text(itemCount, format: .number)

// Currency — uses the user's locale + a specific currency
Text(price, format: .currency(code: "USD"))

// Dates — chooses 12h/24h, day-month-year order, locale-specific weekday names
Text(timestamp, format: .dateTime.year().month().day())

// Strings via .formatted() helpers
let formatted = price.formatted(.currency(code: "USD"))
```

- **`Text(_:format:)` initializers and `.formatted()`** are the right entry points. Avoid `DateFormatter` / `NumberFormatter` instantiation in view code; if you need them, cache as a `static let` (init is expensive) or use the modern `FormatStyle` types.
- **Accept `Locale` as a parameter** in code that produces formatted strings outside SwiftUI views, so tests can pass a fixed locale.

## Right-to-Left (RTL) Support

- **Use leading/trailing**, never **left/right**, in layout APIs (`.padding(.leading, ...)`, `HStack` natural ordering). SwiftUI mirrors leading/trailing automatically under RTL locales.
- **Test with the RTL pseudo-language**: Edit Scheme → Run → Options → App Language → "Right-to-Left Pseudolanguage." This catches hardcoded `.left`/`.right` and unflippable images.
- **Mirror images that have a directional meaning** (back arrows, progress indicators) via `.flipsForRightToLeftLayoutDirection(true)`. Don't mirror images that don't (a person's photograph, a logo).
- **Numbers, dates, prices stay left-to-right** even inside RTL paragraphs — the system handles bidi runs; don't override.

## Translator Context

A translator opening `Localizable.xcstrings` sees only the key and the source string. Without context, *"Save"* is ambiguous (verb? noun? what's being saved?).

- **Provide a `comment:` on every entry** when using `String(localized:)`:

  ```swift
  static let saveButton = LocalizedStringResource(
      "settings.save_button",
      defaultValue: "Save",
      comment: "Label on the button that persists the user's edits in the settings screen."
  )
  ```

- **Key naming carries context too** — `settings.save_button` says where it appears; `save` alone doesn't.
- **Avoid abbreviations in keys**: `nav.title.home` over `nv.t.h`. Translators don't have your project map.

## Pseudo-Localization for Testing

- **Set the run scheme's App Language to "Double-Length Pseudolanguage"** to catch truncation bugs (German is roughly 30% longer than English; Finnish more).
- **"Accented Pseudolanguage"** surfaces hardcoded English (anything that doesn't show up with diacritics is unlocalized).
- **Add a CI screenshot test on the longest pseudo-locale** for critical screens — catches regressions before translators do.

## Common Pitfalls

- **Hardcoded English literals.** `Text("Save")`, `Button("Cancel") { ... }`, `Alert(title: Text("Error"))`. All of these need to come from the facade.
- **String concatenation for sentences.** `"\(user.name) sent you a message"` — translators can't reorder. Use a parameterized resource: `Strings.Notifications.userSentMessage(user.name)`.
- **Singular/plural via `?:`.** `count == 1 ? "item" : "items"` — use plural variations.
- **`String(format: "%.2f", price)`** — pass through `.formatted(.currency(code:))` instead.
- **`DateFormatter()` allocated per render.** Either use the modern `FormatStyle` API or hold a `static let` formatter.
- **`NSLocalizedString` directly in views.** Route through the facade.
- **`.left` / `.right` in modifiers.** Use `.leading` / `.trailing`.
- **Localized strings missing `comment:`.** Translators get ambiguity; you get bug reports.
- **Hardcoded English in accessibility attributes** — see [`apple-accessibility-best-practices.md`](./apple-accessibility-best-practices.md). The facade applies to a11y too.
- **Per-view date formatters.** Centralize via a small formatting utility or use `Text(date, format: ...)`.

## Patterns to Follow

```swift
// Strings module — single source of truth
public enum Strings {
    public enum NavigationTitles {
        public static let home = LocalizedStringResource(
            "navigation.home",
            defaultValue: "Home",
            comment: "Tab bar / nav title for the home screen."
        )
    }

    public enum Notifications {
        public static func userSentMessage(_ userName: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "notifications.user_sent_message",
                defaultValue: "\(userName) sent you a message.",
                comment: "Push-notification body. %@ is the sender's display name."
            )
        }
    }

    public enum Items {
        public static func count(_ value: Int) -> LocalizedStringResource {
            LocalizedStringResource(
                "items.count",
                defaultValue: "\(value) items",
                comment: "Item-count label. Plural variations defined in the String Catalog."
            )
        }
    }
}

// Consuming view
struct HomeView: View {
    let count: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(Strings.NavigationTitles.home)
                .font(.largeTitle)

            Text(Strings.Items.count(count))      // plural-aware
                .accessibilityLabel(Strings.Items.count(count))
        }
        .padding(.leading)                         // RTL-safe (not .left)
    }
}

// View that needs a `String` (e.g., for an accessibility identifier)
let title = String(localized: Strings.NavigationTitles.home)
```
