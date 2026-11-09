# Apple Modular Architecture (full reference)

The long form of the `apple-modular-architecture.md` rule, loaded only when this skill needs the detail. The rule keeps a short checklist; everything below is the complete guidance.

The target shape is a **thin Xcode app target** that holds almost no code, on top of a **local Swift package** where the real app lives, split into many small modules. The `.xcodeproj` owns the bundle, entitlements, Info.plist, and app icon. Everything else is a package module that the app links.

This rule covers the *architecture decision* and *migration*. For authoring the manifest itself (tool-version, products, resources, settings), see [`apple-spm-package-conventions.md`](../../../rules/apple-spm-package-conventions.md). To scaffold the package, use the bundle's [`scripts/scaffold-spm-package.sh`](../../../../scripts/scaffold-spm-package.sh). To plan a module graph, audit one, or migrate an existing app step by step, invoke the **`swift-modularization-pro`** skill. For a manifest and public-API review, invoke `swift-package-pro`.

> **Reference layout: KozBon.** `KozBonPackages/` holds 15 modules and over 1,200 Swift Testing tests. The app target is two Swift files totalling about 130 lines: an `@main` that returns `AppCoreScene()`, and the `AppShortcutsProvider` Xcode requires there. Every test runs with `swift test --package-path KozBonPackages`. BasicSwiftUtilities follows the same per-module `Sources/` + `Tests/` layout and `makeTargets()` manifest.

## Why a local package, not "all code in the .xcodeproj"

- **Build speed.** SPM compiles and caches each module independently and in parallel. Touching a leaf module recompiles that module, not the world. A monolithic app target recompiles far more on every change.
- **Enforced boundaries.** A module can only use what it explicitly declares as a dependency. Layering violations become *compile errors* instead of conventions nobody enforces. The dependency graph is the architecture, written down.
- **Testability without the app host.** `swift test` runs module tests headless and fast, with no simulator boot. Logic stranded in the app target can only be tested through a UI host.
- **Faster SwiftUI iteration.** Previews and incremental builds operate on a small module, not the whole app.
- **Reuse across targets.** Widgets, App Intents extensions, a watch app, a share extension, and the main app all link the same modules. None of them can reach code in the app target.
- **Mechanical sympathy with AI agents.** A small, well-named module with a declared dependency surface is a tractable unit for an agent to read, change, and test. The boundary keeps a change from rippling repo-wide.

## The target layout

```
MyApp/
├── MyApp.xcworkspace          # opens the project + the local package together
├── MyApp.xcodeproj            # thin: targets, signing, capabilities
├── MyApp/                     # the app target's handful of files (see below)
│   ├── MyAppApp.swift         # @main — returns AppCore's root scene, nothing else
│   ├── Info.plist, MyApp.entitlements, Assets.xcassets, PrivacyInfo.xcprivacy
│   └── InfoPlist.xcstrings    # and any other main-bundle-only catalogs
└── MyAppPackages/             # the local Swift package — the actual app
    ├── Package.swift          # makeTargets() helper; one block per module
    ├── Core/                  # foundation: no app-domain deps
    │   ├── Sources/
    │   └── Tests/
    ├── Models/
    ├── Feature.../            # one module per feature
    └── AppCore/               # umbrella: root scene + composition; the app links this
```

- **One directory per module**, each with `Sources/` and `Tests/` (and `Sources/Resources/` when it ships assets or strings). This is exactly what `makeTargets()` and `scaffold-spm-package.sh` assume.
- **The app target links the umbrella product** (`AppCore`) and ideally nothing else, so adding a feature never touches the `.xcodeproj`.
- **A workspace (or the project's local package reference) holds both**, so Xcode indexes, builds, and previews the package alongside the app.

## What stays in the app target — and only this

The app target keeps what Xcode or the system requires to live in the main bundle:

- **The `@main` `App`**, reduced to composing the umbrella's root scene:

  ```swift
  import SwiftUI
  import AppCore

  @main
  struct MyAppApp: App {
      var body: some Scene { AppCoreScene() }
  }
  ```

- **Info.plist, entitlements, the app icon and launch assets, `PrivacyInfo.xcprivacy`.**
- **`InfoPlist.xcstrings`.** The system reads it from the main bundle (see [`apple-infoplist-localization.md`](../../../rules/apple-infoplist-localization.md)).
- **The `AppShortcutsProvider`, plus the catalogs App Intents metadata and Siri phrases resolve against.** Xcode extracts and localizes App Shortcuts only for the app target, and App Intents `LocalizedStringResource`s must use the main bundle. Keep the intents and entities themselves in a package module (KozBon's `BonjourAppIntents`). Leave only the provider and its strings in the app target.
- **Other extension targets** (widgets, share, watch) are separate thin targets that link package products. They never reach into each other's or the app's sources.

Anything else in the app target is a migration candidate. A `ViewModel`, a service, or a view file there is a finding.

## Dependency direction (the part that pays off)

Keep the graph a DAG that flows one way. A workable layering:

1. **Core / foundation**: logging, utilities, dispatch. Zero app-domain dependencies.
2. **Domain**: `Models`, `Storage`, `Localization`. Depend on Core only.
3. **Feature modules**: one per feature area. Depend on domain + Core. **Features do not depend on each other.**
4. **UI / design system**: shared components feature modules use (see [`apple-design-system.md`](../../../rules/apple-design-system.md)).
5. **`AppCore` umbrella**: depends on all feature modules and hosts the root composition (scene, routing, app-level wiring). The app target links this.

Rules of the road:

- **No cycles.** SPM rejects them, but design so the question never comes up.
- **Cross-feature needs go *down*, not sideways.** If feature A needs something from feature B, the shared piece moves down into a module both depend on. Never add a feature→feature edge.
- **A low-level module takes the dependency it needs directly**, rather than reaching it transitively through a higher-level module. For example, KozBon's `LocalNetworkMonitor` takes `Core` directly instead of via `BonjourCore`.
- **Only export what consumers need.** Each module's `products`/public API is its contract; internal types stay internal. With `InternalImportsByDefault` (see SPM conventions), imports are `internal` unless re-exported with `public import`.

## Interface and implementation modules

When a capability has several interchangeable backends, split it into three kinds of module:

```
BonjourAICore        # protocols + value types every backend and consumer shares
BonjourAIApple       # one module per backend; each depends on the interface module only
BonjourAIAnthropic
BonjourAIGemini
BonjourAI            # umbrella: picks a backend at runtime (routing factories)
```

- **Consumers depend on the interface module** (or the umbrella), never on a specific backend. Features stay compilable and testable when a backend is removed, and only the module that actually imports a heavy SDK pays for it.
- **Backend-specific resources** (brand images, prompts) ship in the backend module with `Bundle.module`, not in a shared UI module.
- The same split works for analytics providers, payment processors, or a `Storage` interface with a SwiftData implementation and an in-memory test implementation.

## Re-exports

- `@_exported import Core` in a module's `Exports.swift` makes `Core` visible to every importer. This is handy for a foundation logger, or for keeping `import BonjourAI` working after its types moved into `BonjourAICore`.
- **Use it sparingly and say why in the file.** Each re-export hides a dependency edge from readers and the manifest. Prefer declaring the dependency where it is used. `@_exported` is underscored (unofficial) syntax, so keep it to a couple of deliberate places.

## Tests live in the package

- **Every module has a `Tests/` target**, and `swift test --package-path MyAppPackages` is the test runner for the whole app. The app scheme needs no unit-test action. Keep UI tests (XCUITest) in the Xcode project, because they need an app host.
- **Test targets inherit the module's dependencies**, so tests can build fixtures from sibling domain types without boilerplate. Add extras only for test-only needs (KozBon's `makeTargets(additionalTestDependencies:)`).
- **CI runs `swift build` + `swift test` on package changes**, path-filtered to the package directory. It is much faster than an `xcodebuild` app build, which runs separately.
- Some resources need `xcodebuild`. A `.xcdatamodeld` can't be compiled by the SwiftPM CLI, so guard those tests (see below).

## Document the graph

Keep a module table (module · purpose · key types) and the dependency graph in the repo's `CLAUDE.md`, as KozBon does. Agents and new contributors read it first. Update it in the same change that adds, splits, or removes a module.

## Migrating an existing .xcodeproj-only app

Do it incrementally, never as a big-bang move. Each step keeps the app building.

1. **Scaffold the package.** Run `scripts/scaffold-spm-package.sh <repo> --name <App>Packages --modules Core,AppCore` to create `<App>Packages/` with the `makeTargets()` manifest and module skeletons. Add it to the Xcode project (File ▸ Add Package Dependencies ▸ Add Local) and link the `AppCore` product to the app target.
2. **Move a leaf first.** Pick code with the fewest dependencies, usually foundation utilities, and move it to `Core`. Move the files into `Core/Sources/`, make the needed symbols `public`, and fix imports. Build.
3. **Work up the layers.** Move models, then storage, then feature areas one at a time. After each move the app must still build and the tests must pass; that invariant is what makes this safe.
4. **Move the root composition into `AppCore`.** Move the root view, the scene, and dependency wiring there, until the app's `@main` just returns `AppCoreScene()`.
5. **Move tests with their code.** As logic leaves the app target, its XCTest/Swift Testing files move to the module's `Tests/` and run under `swift test`.
6. **Stop when the app target holds only what the section above lists.** New feature code defaults to a module, never to the app target.

Don't try to perfect the module graph up front. Start with `Core` + `AppCore`, and split modules out as boundaries become obvious.

## Resource & Core Data caveats

- **Use `Bundle.module`, never `Bundle.main`**, for resources inside a module (string catalogs, asset catalogs, JSON). `Bundle.main` is the *app's* bundle, not the module's. It works in a quick test and breaks in production.
- **Strings a module owns resolve against `Bundle.module`**, which is why App Intents metadata strings can't live in a module (see the app-target section above).
- **The SwiftPM CLI can't compile `.xcdatamodeld`.** A module shipping a Core Data model builds under `xcodebuild` but not plain `swift build`. KozBon's `BonjourStorage` guards its Core Data tests on a model-availability check, skips them under `swift test`, and asserts under `xcodebuild test`. Plan for the split test path, or build the `NSManagedObjectModel` programmatically (see the `coredata-swift6-pro` skill).

## Common Pitfalls

- **Leaving logic in the app target "for now."** It compounds: app-target code can't be unit-tested headless, can't be reused by extensions, and recompiles on every app change. New code defaults to a module.
- **Feature-to-feature dependencies.** This shortcut turns the graph into a ball of mud. Push the shared piece down a layer.
- **One giant module.** A single `App` module with everything in it costs the package overhead without the build-parallelism or boundary-enforcement payoff. Split by feature.
- **Features importing a concrete backend** (`BonjourAIAnthropic`) instead of the interface module. Every feature then links that SDK and can't be tested without it.
- **`@_exported import` as a shortcut for missing dependency declarations.**
- **Moving the `AppShortcutsProvider` into a package.** It builds, but Siri phrases are never extracted or localized.
- **Hand-writing `.target`/`.testTarget` pairs.** Use `makeTargets()`: uniform settings, no copy-paste drift. See `apple-spm-package-conventions.md`.
- **`Bundle.main` for module resources**, the silent production break.
- **Over-designing the graph before code exists.** Start with `Core` + `AppCore`; let real dependencies pull modules apart.
