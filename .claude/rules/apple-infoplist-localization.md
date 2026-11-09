---
description: Localizing Info.plist strings on Apple platforms — InfoPlist.xcstrings vs InfoPlist.strings, the INFOPLIST_KEY_* build-settings base value, per-target catalogs, and purpose strings that survive App Store review
globs: "Info.plist,**/Info.plist,**/InfoPlist.xcstrings,**/InfoPlist.strings,**/*.xcconfig"
paths:
  - "Info.plist"
  - "**/Info.plist"
  - "**/InfoPlist.xcstrings"
  - "**/InfoPlist.strings"
  - "**/*.xcconfig"
must:
  - "Every purpose string has a base value in the Info.plist or build settings; catalogs only add translations."
  - "Declare only the `NS*UsageDescription` keys you use, and say what the data does for the user."
  - "Mark identifiers (bundle IDs, URL schemes, UTTypes) do-not-translate."
---

# Info.plist Localization

Info.plist strings are user-facing — the app name under the icon, and the purpose string inside every system permission dialog — but they reach the user through a **completely different channel** than the rest of your UI. The *system* reads them, not your code. Two consequences make this its own rule:

- **The type-safe `Strings` facade cannot reach them.** [`apple-localization-best-practices.md`](./apple-localization-best-practices.md) requires every UI string to route through the facade so a typo is a compile error. Info.plist strings are the documented exception — there is no Swift call site to route through.
- **Apple owns the keys.** You localize `NSCameraUsageDescription` and `CFBundleDisplayName` *by those exact names*, so the descriptive-key-naming convention doesn't apply either.

Treat it as a small separate pipeline with its own failure modes — most of which fail silently, or at upload, rather than at build.

## The Two Mechanisms

**Modern — `InfoPlist.xcstrings`.** Create a String Catalog named **exactly** `InfoPlist.xcstrings` and add it to the target. After each build Xcode automatically extracts the known localizable Info.plist keys into it; from there the normal catalog editor and export/import workflow applies.

**Legacy — `InfoPlist.strings`.** One per `<lang>.lproj/`, plain key-value:

```
/* Shown under the app icon on the Home Screen */
"CFBundleDisplayName" = "Mon App";

/* Camera permission dialog */
"NSCameraUsageDescription" = "Scanne les codes-barres pour ajouter des articles sans les saisir.";
```

Prefer the catalog for new work. Leave a stable legacy `InfoPlist.strings` alone rather than migrating mid-release — but **never run both for the same target**: two sources for one key is an afternoon of debugging.

## The Base Value Lives in Build Settings

Modern Xcode projects often ship **no `Info.plist` file at all** — it's generated from `INFOPLIST_KEY_*` build settings (`INFOPLIST_KEY_NSCameraUsageDescription`, …) set on the target or in an `.xcconfig`. That changes where the *source* string lives, and it's where the silent failures come from:

- **The build setting (or plist entry) is the base/fallback value** — what users see in any language you haven't translated, including your development language.
- **The catalog supplies per-language overrides.** It does not replace the base value.
- **A purpose string must exist as a base value.** Declaring the key *only* in `InfoPlist.strings` / `.xcstrings` is what produces **`ITMS-90683: Missing Purpose String in Info.plist`** at upload — the key looks present to you and absent to Apple's validator.
- **Untranslated rows don't take effect.** A catalog entry still in the **new / untranslated** state falls back to the base value, so a half-finished translation ships silently in the development language. Check the catalog's state column before release, not just that rows exist.

## One Catalog Per Target

Give **each target its own `InfoPlist.xcstrings`** — app, share extension, widget, watch app. A single shared catalog means every target shares one `CFBundleDisplayName`, so you can't translate the app's name without renaming the extensions along with it. This is the most common structural mistake in multi-target projects.

## What's Worth Localizing

- **`CFBundleDisplayName`** — the name under the icon. Xcode extracts it automatically and **you can't turn that off**; it regenerates on export so translators always see it. Decide deliberately: many brands don't translate their name, in which case mark it *do not translate* rather than leaving it looking forgotten.
- **Every `NS*UsageDescription` you ship** — camera, microphone, photo library (and the add-only variant), location (each variant), contacts, calendar, reminders, Bluetooth, speech recognition, Face ID (`NSFaceIDUsageDescription`), local network, tracking (`NSUserTrackingUsageDescription`), and newer capability keys. These are the **highest-visibility strings in the app**: they appear in a modal the user must answer before the feature works.
- **`CFBundleName`**, plus shortcut / App Intent titles surfaced through the plist.
- **`NSHumanReadableCopyright`** on macOS.
- **Never localize identifiers** — bundle IDs, URL schemes, `UTType` identifiers, background-mode strings. Mark them *do not translate* so a translator doesn't helpfully localize a URL scheme and break the app in exactly one locale.

## Purpose Strings Are Reviewed

App Review reads these, and vague or placeholder text is a documented rejection reason. The bar is a specific sentence framed around user benefit:

```
❌ "This app needs your location."         // vague — states no purpose
❌ "Required for functionality."            // placeholder
❌ "We use Bluetooth."                      // names nothing the app does
✅ "Shows nearby stores and estimates delivery time."
✅ "Scans barcodes so you can add items without typing."
```

- **Say what the app does with the data and why it helps the user** — not that a framework demands it.
- **Only declare keys for capabilities you actually use.** A key left behind by a removed feature is both a rejection trigger and a privacy smell — audit the list each release.
- **Translations must stay equally specific.** A precise English string with a generic French one fails the same review in a different market.
- These are **separate from** the privacy manifest's `NSPrivacyAccessedAPITypes` (see [`apple-testflight-deployment.md`](./apple-testflight-deployment.md)). You need both; neither substitutes for the other.

## Translator Context

A translator sees a bare key like `NSPhotoLibraryAddUsageDescription` and no screenshot. Add a comment per entry saying **where it appears and what's being asked for** — the String Catalog's comment field, or a `/* … */` above the legacy entry. Mark brand names and identifiers *do not translate* so the catalog flags them explicitly instead of leaving translators guessing.

## Verifying

- Run in a target locale (scheme ▸ Run ▸ App Language) and **trigger the actual permission dialogs** — reading the catalog proves nothing about what the system renders.
- Check the app name **under the icon on the Home Screen**, not just in Xcode.
- Confirm the base value reached the built product: inspect the generated `Info.plist` inside the `.app` bundle rather than trusting build settings.
- Put the permission-dialog pass on the release checklist for each shipped locale — these strings are invisible to normal QA until a permission is actually requested.

## Common Pitfalls

- **Expecting the `Strings` facade to cover them** — it can't; there's no call site. This is the exception, and the reason this rule exists.
- **Key localized with no base value** → `ITMS-90683` at upload.
- **Catalog rows left in the *new* state** → silently ships the development language.
- **One shared `InfoPlist.xcstrings` across targets** → can't translate the app name independently.
- **`InfoPlist.strings` and `InfoPlist.xcstrings` both live for one target** → ambiguous source of truth.
- **Misspelled or wrong-cased keys** — they fail silently; the system just uses the base value.
- **Vague or placeholder purpose strings** — a documented App Review rejection.
- **Stale keys for removed features** — rejection trigger and privacy smell.
- **Localizing identifiers** (URL schemes, bundle IDs, background modes) — breaks the app in that locale.
