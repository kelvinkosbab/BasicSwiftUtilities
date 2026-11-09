---
description: Conventions for authoring Swift Package Manager Package.swift files — tool-version pinning, platforms, products, per-module folder layout, resources, modern features, dependency hygiene
globs: "Package.swift,**/Package.swift"
paths:
  - "Package.swift"
  - "**/Package.swift"
must:
  - "`// swift-tools-version:` first, `platforms:` always declared, and `.swiftLanguageMode(.v6)` in shared settings."
  - "Use `Bundle.module`, never `Bundle.main`, for package resources."
  - "Never ship `branch:`, `revision:`, path dependencies, or `.unsafeFlags` in a release."
  - "Commit `Package.resolved` for apps; ignore it for libraries."
---

# Swift Package Manager: Package.swift Conventions

The must-follow rules for a manifest. Examples, rationale, and edge cases live in [`swift-package-pro/references/manifest-conventions.md`](../skills/swift-package-pro/references/manifest-conventions.md); read the matching section only when a line below isn't enough. Start a new package from the bundle's `templates/Package.template.swift`.

## Manifest

- **`// swift-tools-version:` is the first line**, set to the lowest version with the features you use. Bump it only to adopt a feature.
- **Always declare `platforms:`** with the minimums you actually support, in one spelling style (`.iOS(.v17)`).
- **One product per separable feature**; internal-only modules aren't products. Leave library `type:` unset.
- **Per-module layout**: `{Module}/Sources/` and `{Module}/Tests/`, resources in `{Module}/Sources/Resources/`. `path:` strings match the disk 1:1.
- **Two or more similar modules → a `makeTargets()` helper** (the template's), so a new module is one `products:` line plus one `+ makeTargets(...)` block. Never hand-write `.target`/`.testTarget` pairs.

## Swift settings

- **Pin `.swiftLanguageMode(.v6)`** in one `sharedSwiftSettings` used by every source and test target. `.v5` only with a dated migration plan, as a commented per-target override.
- **Opt into upcoming features deliberately**: `InternalImportsByDefault` (then `public import` only for types in your public API), `ExistentialAny` as its own migration. Don't mix `enableExperimentalFeature` and `enableUpcomingFeature` for one feature.
- **No `.unsafeFlags` in a published library** (use `.treatAllWarnings(as: .error)` at tools 6.2 instead of `-warnings-as-errors`), and no `-ld_classic` anywhere (removed in Xcode 27).
- **App packages at tools 6.2: UI and feature modules get `.defaultIsolation(MainActor.self)`**; Core, data, and published libraries stay nonisolated (`scaffold-spm-package.sh --main-actor all`).
- Use `.when(platforms:)` / `.when(configuration:)` only for settings that genuinely vary.

## Resources

- **`.process(...)` by default**; `.copy(...)` only for files that must ship verbatim.
- **`Bundle.module`, never `Bundle.main`**, for packaged resources.
- SwiftPM's CLI can't compile `.xcdatamodeld`; plan an `xcodebuild` path or build the model in code (`coredata-swift6-pro`).

## Dependencies

- **`from:`** for SemVer-honoring packages, **`exact:`** for executables or packages that don't honor SemVer. Never ship `branch:`, `revision:`, or `.package(path:)` in a release.
- Declare each package once at the top level and reference products by `.product(name:package:)`.
- **`Package.resolved`: commit it for apps, git-ignore it for libraries.**

## Tests and plugins

- Every module has a test target; UI tests stay in the Xcode project.
- Build-tool plugins (SwiftLint) attach per target and are version-pinned like any dependency.
