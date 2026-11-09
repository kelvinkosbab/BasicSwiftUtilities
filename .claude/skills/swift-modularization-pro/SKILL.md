---
name: swift-modularization-pro
description: Plans, audits, and migrates Apple apps to a modular local Swift package (the KozBon layout) — a thin app target over Core, domain, feature, interface/implementation, and AppCore umbrella modules, with tests under swift test. Use when modularizing an existing .xcodeproj app, designing a new app's module graph, splitting an oversized module, or reviewing whether a package's dependency graph and app target are healthy.
license: MIT
metadata:
  author: AppBootstrapAI contributors
  version: "1.0"
  grounded_in: "KozBon (KozBonPackages, 15 modules), BasicSwiftUtilities, Swift Package Manager documentation, the apple-modular-architecture rule"
---

Turn an Apple app into a thin app target over a local Swift package of small modules, or check one that already is. This is the deep companion to the always-on `apple-modular-architecture.md` rule. The rule steers while writing; this skill plans a graph, audits a whole package, and drives a migration one module at a time.

Pick the mode from the request:

- **Plan**: a new app, or an existing app before any move. Produce a module map (module · layer · purpose · dependencies) and the order to extract them, using `references/module-graph.md`. Start small (`Core`, a domain module or two, one feature, `AppCore`) and say which later splits you'd expect.
- **Migrate**: move code out of the app target, or out of an oversized module, following `references/migration.md`. One module per step, the app building and tests passing after each.
- **Audit**: an app that already has a package. Run the checks in `references/audit.md`, then report findings ranked by severity.

Review process (audit mode):

1. Inventory: list the modules, the app target's Swift files and line counts, and every extension target. Use `references/audit.md` ("Inventory").
2. Check the app target against "What stays in the app target" in `references/migration.md`. Any view, view model, or service there is a finding.
3. Check the graph using `references/module-graph.md` and the dependency script in `references/audit.md`: layer violations, feature→feature edges, consumers importing concrete backends, cycles, oversized or near-empty modules, undeclared reliance on `@_exported`.
4. Check resources and tests: `Bundle.main` inside modules, modules without a `Tests/` target, tests that only run under `xcodebuild` without a reason, and whether CI runs `swift test` on package changes.

If doing a partial review, load only the relevant reference file.

## Core Instructions

- **The app target is a shell.** It keeps `@main`, Info.plist, entitlements, assets, the privacy manifest, `InfoPlist.xcstrings`, and the `AppShortcutsProvider` with its main-bundle catalogs. Everything else belongs in a module.
- **Direction is the architecture.** Core ← domain ← features ← `AppCore`. Features never import each other; shared needs move down a layer.
- **Interfaces before implementations.** When a capability has interchangeable backends (AI providers, analytics, storage), consumers depend on an interface module and an umbrella picks the backend. A feature importing a concrete backend is a finding, unless the UI is specifically about that backend (a provider picker).
- **Incremental, never big-bang.** Every plan step leaves the app building, tests green, and the change reviewable on its own. Never propose moving every file in one pass.
- **Every module is testable headless.** It has a `Tests/` target and passes under `swift test`. The exceptions are resources the SwiftPM CLI can't compile, such as `.xcdatamodeld`, and those are guarded and documented.
- **Granularity follows real boundaries.** Split a module when it has two reasons to change, a heavy dependency only part of it needs, or other targets (widgets, intents) need part of it. Don't split speculatively. A module with one tiny file and one consumer probably belongs to that consumer.
- **Use the bundle's tools.** Scaffold with `scripts/scaffold-spm-package.sh` and keep `makeTargets()` in the manifest (`templates/Package.template.swift`). Manifest settings follow `apple-spm-package-conventions.md`.
- **Severity by cost**: broken (a cycle, `Bundle.main` resources in a module, Siri phrases lost because the `AppShortcutsProvider` moved) > boundary leak (feature→feature edge, a concrete backend imported by features, logic in the app target, an `@_exported` hiding a missing dependency) > shape (oversized or near-empty modules, a missing graph doc in `CLAUDE.md`).
- Cross-reference, don't duplicate: public API and manifest details go to `swift-package-pro`, concurrency under the new boundaries to `swift-concurrency-pro`, Core Data in a package to `coredata-swift6-pro`, and design-system module contents to `swift-design-system-pro`.

## Output Format

**Plan mode:** a module table (module · layer · purpose · depends on), a Mermaid or indented-text graph, the extraction order with one line per step, and what the app target will contain at the end.

**Migrate mode:** for each step, the files moved, the symbols made `public`, the manifest change (one `products:` line and one `makeTargets` block), and the commands run to verify it (`swift build`, `swift test`, and an `xcodebuild` build of the app scheme).

**Audit mode:** findings grouped by module (or by "App target"). Each finding gives the file or manifest line, the violated principle, why it costs something (build time, testability, reuse, a runtime break), and a brief before/after. Skip clean modules. End with an inventory table and a prioritized plan.

Example finding:

### Package.swift — `FeatureSettings`

**`FeatureSettings` depends on `FeatureAccount` to show the signed-in user's avatar. This is a feature→feature edge: a change in Account now rebuilds and can break Settings, and neither feature can be previewed without the other.**

```swift
// Before
+ makeTargets(name: "FeatureSettings", dependencies: ["Core", "Models", "FeatureAccount"])

// After — the shared piece moves down to a module both features already use
+ makeTargets(name: "FeatureSettings", dependencies: ["Core", "Models", "DesignSystem"])
// `AvatarView` moved from FeatureAccount to DesignSystem; it takes a URL and a name, not an Account model.
```

### Summary

| Inventory | Count |
|---|---|
| Modules | 9 |
| Swift files in the app target (excluding `@main` / `AppShortcutsProvider`) | 14 |
| Feature→feature edges | 1 |
| Modules without a test target | 2 |
| `Bundle.main` in module sources | 3 |

1. **Broken:** `Bundle.main` image loads in `DesignSystem` render nothing in production. Use `Bundle.module`.
2. **Boundary leak:** 14 app-target files, including `SettingsViewModel`. Move them to `FeatureSettings` with their tests.
3. **Boundary leak:** the `FeatureSettings` → `FeatureAccount` edge.
4. **Shape:** add test targets for `Models` and `Localization`, and add the module table to `CLAUDE.md`.

End of example.

## References

- `references/module-graph.md` — layers and allowed edges, module kinds (foundation, domain, feature, interface/implementation, umbrella, design system, app-intents), naming, granularity heuristics, extension targets, a worked example graph.
- `references/migration.md` — what must stay in the app target and why, the extraction order, per-step checklist, access control and `Bundle.module` fixes, moving tests, App Intents and Core Data special cases, CI.
- `references/audit.md` — inventory commands, a dependency-rule check script over `swift package dump-package`, searches for `Bundle.main` / `@_exported` / app-target logic, and the CI job.
- `references/architecture-conventions.md` — the full `apple-modular-architecture` rule (the installed rule is its checklist): why a local package, target layout, migration, resource and Core Data caveats.
