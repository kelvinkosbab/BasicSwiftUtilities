---
description: Structure Apple apps as a thin Xcode app shell over a fat local Swift package with many small modules — the architecture, why it wins, and how to migrate an existing .xcodeproj-only app incrementally
globs: "Package.swift,**/Package.swift,**/*App.swift"
---

# Apple Modular Architecture (local SPM package)

The target shape: a **thin Xcode app target** that holds almost no code, sitting on top of a **local Swift package** where the real app lives — split into many small modules. The `.xcodeproj` owns the bundle, entitlements, Info.plist, and app icon; everything else is a package module the app links.

This rule covers the *architecture decision* and *migration*. For authoring the manifest itself (tool-version, products, resources, settings), see [`apple-spm-package-conventions.md`](./apple-spm-package-conventions.md). To scaffold the package, use the bundle's [`scripts/scaffold-spm-package.sh`](../../scripts/scaffold-spm-package.sh). For a deep manifest/API review, invoke the `swift-package-pro` skill.

> **Reference layout.** This is how KozBon (`KozBonPackages/`) and BasicSwiftUtilities are organized — a single local package at the repo root, one directory per module, a `makeTargets()` helper in `Package.swift`, and an `AppCore` umbrella the app target links.

## Why a local package, not "all code in the .xcodeproj"

- **Build speed.** SPM compiles modules independently and in parallel, and caches per module. Touching a leaf module recompiles that module, not the world. A monolithic app target recompiles far more on every change.
- **Enforced boundaries.** A module can only use what it explicitly declares as a dependency. Layering violations become *compile errors* instead of conventions nobody enforces — the dependency graph is the architecture, written down.
- **Testability without the app host.** `swift test` runs module tests headless, fast, no simulator boot. Logic stranded in the app target can only be tested through a UI host.
- **Faster SwiftUI iteration.** Previews and incremental builds operate on a small module, not the whole app.
- **Reuse across targets.** Widgets, App Intents extensions, a watch app, a share extension, and the main app all link the same modules. Code in the app target is reachable by none of them.
- **Mechanical sympathy with AI agents.** A small, well-named module with a declared dependency surface is a tractable unit for an agent to read, change, and test — the boundary keeps a change from rippling repo-wide.

## The target layout

```
MyApp/
├── MyApp.xcodeproj            # thin: @main App, entitlements, Info.plist, app-icon asset catalog
├── MyApp/                     # the app target's handful of files
│   └── MyAppApp.swift         # @main — wires the root view from AppCore, nothing else
└── MyAppPackages/             # the local Swift package — the actual app
    ├── Package.swift          # makeTargets() helper; one block per module
    ├── Core/                  # foundation: no app-domain deps
    │   ├── Sources/
    │   └── Tests/
    ├── Models/
    │   ├── Sources/
    │   └── Tests/
    ├── Feature.../            # one module per feature
    └── AppCore/               # umbrella: depends on every feature module; the app links this
        ├── Sources/
        └── Tests/
```

- **One directory per module**, each with `Sources/` and `Tests/` (and `Sources/Resources/` when it ships assets/strings). This is exactly what `makeTargets()` and `scaffold-spm-package.sh` assume.
- **The app target links the umbrella product** (`AppCore`) and ideally nothing else — so adding a feature never touches the `.xcodeproj`.

## Dependency direction (the part that pays off)

Keep the graph a DAG that flows one way. A workable layering:

1. **Core / foundation** — logging, utilities, dispatch. Zero app-domain dependencies.
2. **Domain** — `Models`, `Storage`, `Localization`. Depend on Core only.
3. **Feature modules** — one per feature area. Depend on domain + Core. **Features do not depend on each other.**
4. **UI / design system** — shared components feature modules use.
5. **`AppCore` umbrella** — depends on all feature modules; hosts the root composition (routing, app-level wiring). The app target links this.

Rules of the road:

- **No cycles.** SPM rejects them, but design so the question never comes up.
- **Cross-feature needs go *down*, not sideways.** If feature A needs something from feature B, the shared piece moves down into a module both depend on — not a feature→feature edge.
- **A low-level module takes the dependency it needs directly**, rather than reaching it transitively through a higher-level module (see KozBon's `LocalNetworkMonitor` taking `Core` directly instead of via `BonjourCore`).
- **Only export what consumers need.** Each module's `products`/public API is its contract; internal types stay internal. With `InternalImportsByDefault` (see SPM conventions), imports are `internal` unless re-exported with `public import`.

## Migrating an existing .xcodeproj-only app

Do it incrementally — never a big-bang move. Each step keeps the app building.

1. **Scaffold the package.** Run `scripts/scaffold-spm-package.sh <repo> --name <App>Packages --modules Core,AppCore` to create `<App>Packages/` with the `makeTargets()` manifest and module skeletons. Add it to the Xcode project (File ▸ Add Package Dependencies ▸ Add Local), and link the `AppCore` product to the app target.
2. **Move a leaf first.** Pick code with the fewest dependencies — usually foundation utilities → `Core`. Move the files into `Core/Sources/`, make the needed symbols `public`, fix imports. Build.
3. **Work up the layers.** Models, storage, then feature areas one at a time. After each move, the app still builds and tests pass — that's the invariant that makes this safe.
4. **Thin the app target.** As features land in modules, the app target shrinks toward just `@main` + the root view pulled from `AppCore`.
5. **Stop when the app target is thin.** It doesn't have to reach zero files — but new feature code should default to a module, not the app target.

Don't try to perfect the module graph up front. Start with `Core` + `AppCore`, split modules out as boundaries become obvious.

## Resource & Core Data caveats

- **`Bundle.module`, never `Bundle.main`**, for resources inside a module (string catalogs, asset catalogs, JSON). `Bundle.main` is the *app's* bundle, not the module's — it works in a quick test and breaks in production.
- **`.xcdatamodeld` can't be compiled by the SwiftPM CLI.** A module shipping a Core Data model builds under `xcodebuild` but not plain `swift build`. KozBon's `BonjourStorage` guards Core Data tests on a model-availability check and skips them under `swift test`, asserting under `xcodebuild test`. Plan for the split test path, or build the `NSManagedObjectModel` programmatically (see the `coredata-swift6-pro` skill).

## Common Pitfalls

- **Leaving logic in the app target "for now."** It compounds: app-target code can't be unit-tested headless, can't be reused by extensions, and recompiles on every app change. New code defaults to a module.
- **Feature-to-feature dependencies.** The fast shortcut that turns the graph into a ball of mud. Push the shared piece down a layer.
- **One giant module.** A single `App` module with everything in it gets you the package overhead without the build-parallelism or boundary-enforcement payoff. Split by feature.
- **Hand-writing `.target`/`.testTarget` pairs.** Use `makeTargets()` — uniform settings, no copy-paste drift. See `apple-spm-package-conventions.md`.
- **`Bundle.main` for module resources** — the silent production break.
- **Over-designing the graph before code exists.** Start with `Core` + `AppCore`; let real dependencies pull modules apart.
