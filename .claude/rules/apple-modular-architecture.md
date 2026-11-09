---
description: Structure Apple apps as a thin Xcode app shell over a fat local Swift package with many small modules — the architecture, why it wins, what must stay in the app target, and how to migrate an existing .xcodeproj-only app incrementally
globs: "Package.swift,**/Package.swift,**/*App.swift"
paths:
  - "Package.swift"
  - "**/Package.swift"
  - "**/*App.swift"
must:
  - "Keep the app target thin: `@main`, Info.plist, entitlements, assets, privacy manifest; code lives in a local Swift package."
  - "One directory per module and a `makeTargets()` manifest, with an `AppCore` umbrella the app links."
  - "The module graph flows one way; features never depend on each other's implementation."
  - "Every module is tested under `swift test`."
---

# Apple Modular Architecture (local SPM package)

A thin Xcode app target over a local Swift package of small modules, as KozBon does. This is the checklist; the full rule with the layout, manifest, migration steps, and the reasons is in [`architecture-conventions.md`](../skills/swift-modularization-pro/references/architecture-conventions.md). `swift-modularization-pro` plans, migrates, and audits; `scripts/scaffold-spm-package.sh` creates the skeleton.

## Layout

- **One local package** (`<App>Packages/`), one directory per module with `Sources/` and `Tests/`, manifest built with `makeTargets()` (see [`apple-spm-package-conventions.md`](./apple-spm-package-conventions.md)).
- **An `AppCore` umbrella** that the app target links, and ideally nothing else, so a new feature never touches the `.xcodeproj`.
- **Start small** (`Core` + `AppCore`) and let real dependencies pull modules apart; one giant module gets none of the payoff.

## What stays in the app target

- `@main` returning `AppCoreScene()`, Info.plist, entitlements, app icon and launch assets, `PrivacyInfo.xcprivacy`, and `InfoPlist.xcstrings`.
- **The `AppShortcutsProvider`** and the catalogs App Intents metadata and Siri phrases resolve against. In a package it builds, but phrases are never extracted or localized.
- Extensions (widgets, share, watch) are their own thin targets linking package products.
- New code defaults to a module; logic left in the app target "for now" can't be tested headless or reused.

## Dependencies

- **The graph flows one way, with no cycles.** Features never depend on each other; shared pieces move down a layer.
- **Low-level modules take what they need directly**, not transitively through a higher module.
- **Interfaces for interchangeable backends:** consumers depend on the interface or the umbrella, never on a concrete backend. Backend resources ship in the backend module.
- **`@_exported import` sparingly**, with a comment saying why; never as a substitute for a declared dependency.
- **Public API is the module's contract**; everything else stays internal.

## Resources and tests

- **`Bundle.module`, never `Bundle.main`**, for module resources. App Intents strings stay in the app target for that reason.
- **The SwiftPM CLI can't compile `.xcdatamodeld`**; guard Core Data tests so `swift test` skips them.
- **Every module has a test target**, and `swift test --package-path <App>Packages` runs them all. UI tests stay in the Xcode project. CI runs `swift build` + `swift test` on package changes.
- **Keep a module table in `CLAUDE.md`**, updated with each new module.
