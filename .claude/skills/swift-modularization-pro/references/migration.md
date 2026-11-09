# Migrating to a modular local package

## What stays in the app target

| File | Why it can't move |
|---|---|
| `@main` `App` struct | Xcode needs an entry point in the executable target. Reduce it to `var body: some Scene { AppCoreScene() }`. |
| `Info.plist`, entitlements, `PrivacyInfo.xcprivacy` | Belong to the bundle and signing, not to code. |
| App icon (`.icon` / `AppIcon.appiconset`), launch assets | Read by the system from the main bundle. |
| `InfoPlist.xcstrings` | The system localizes Info.plist keys from the main bundle. |
| `AppShortcutsProvider` | Xcode runs App Shortcuts extraction and localization only for the app target; declared in a package, `autoShortcuts` comes out empty. |
| App Intents metadata catalogs (`Localizable.xcstrings`, `AppShortcuts.xcstrings` in the app) | App Intents requires `LocalizedStringResource`s that resolve against the main bundle. |

Everything else moves: views, view models, services, models, persistence, networking, the root scene, and dependency wiring. Keep intents and entities in a package module, with only the provider and its main-bundle strings left behind.

## Before the first move

1. **Scaffold** with the bundle's script:

   ```bash
   /path/to/AppBootstrapAI/scripts/scaffold-spm-package.sh . --name MyAppPackages --modules Core,Models,AppCore --dry-run
   /path/to/AppBootstrapAI/scripts/scaffold-spm-package.sh . --name MyAppPackages --modules Core,Models,AppCore
   ```

2. **Add the package to the project** (File ▸ Add Package Dependencies ▸ Add Local…, or drag the folder in). Link the `AppCore` product to the app target. A workspace that holds both the project and the package is optional but makes indexing and previews smoother.
3. **Check the baseline**: the app builds with `xcodebuild`, `swift build --package-path MyAppPackages` succeeds, and `swift test --package-path MyAppPackages` passes the placeholder tests.
4. **Add the CI job** (`references/audit.md`) now, so every later step is checked automatically.

## Extraction order

Move leaves first, then work upward. Each row is a separate, reviewable change:

1. **Foundation** → `Core`: logging, extensions on Foundation types, small utilities.
2. **Models** → `Models`: value types, IDs, domain errors.
3. **Strings** → `Localization`: the `Strings` facade and its catalog, with `bundle: .module` lookups (see `apple-localization-best-practices.md`).
4. **Persistence and networking** → `Storage` (and `Networking` if it is large), behind repository protocols (see `apple-repository-pattern.md`).
5. **Design system** → `DesignSystem`: tokens, icons, components (see `swift-design-system-pro`).
6. **One feature at a time** → `FeatureX`: start with the feature that has the fewest inbound references.
7. **Root composition** → `AppCore`: the root view, tab/navigation container, environment wiring, and macOS commands.
8. **Intents** → `AppIntents` module: intents, entities, queries. Leave the provider in the app.

## Per-step checklist

For every move:

- [ ] Move the files on disk into `<Module>/Sources/` (with `git mv` to keep history).
- [ ] Add the module's `.library` product and `makeTargets(...)` block if it is new.
- [ ] Make only the symbols consumers need `public`. Initializers of public structs are internal by default, so add `public init` where callers construct them.
- [ ] Add `import <Module>` where it is now needed. With `InternalImportsByDefault`, use `public import` only where a public signature exposes the dependency's types.
- [ ] Replace `Bundle.main` with `Bundle.module` for anything the module ships (images, colors, catalogs, JSON).
- [ ] Move the matching tests into `<Module>/Tests/`. Convert XCTest to Swift Testing as you go if the project has adopted it.
- [ ] Verify: `swift build` and `swift test` for the package, then build the app scheme with `xcodebuild` (or in Xcode) for each shipped platform.
- [ ] Update the module table and graph in `CLAUDE.md`.

## Common breakages while moving

- **"Cannot find type in scope"** after a move: the type is `internal` in its new module. Make it `public`, or reconsider whether the caller should depend on it at all.
- **Previews stop working**: preview fixtures referenced app-target types. Move the fixtures into the module (inside `#if DEBUG`) or into a test-support module.
- **Images or colors render blank**: `Image("name")` / `Color("name")` look in the main bundle. Use `Image("name", bundle: .module)` or the generated asset symbols in the module.
- **Strings show their keys**: the catalog moved but lookups don't pass `bundle: .module`. Route them through the module's `Strings` facade.
- **`@Observable` or `@MainActor` isolation errors** appear where none existed: a module is compiled in Swift 6 mode while the app target was not. Fix the isolation (see `swift-concurrency-pro`); don't drop the module to Swift 5 mode.
- **A cycle**: two modules need each other. One of them holds a type that belongs lower; move that type down.

## Special cases

- **Core Data models**: `.xcdatamodeld` in a module works under `xcodebuild` but not the SwiftPM CLI. Either guard tests on model availability and skip under `swift test` (KozBon's `BonjourStorage`), or build the `NSManagedObjectModel` in code (see `coredata-swift6-pro`).
- **App-target-only Info.plist reads** (`Bundle.main.object(forInfoDictionaryKey:)`): inject the value from the app or `AppCore` rather than reading `Bundle.main` deep inside a module.
- **Multi-platform apps**: modules declare all platforms in `platforms:`, and platform-specific code uses `#if os(...)` inside the module. Per-platform app targets all link the same `AppCore`.
- **Objective-C code**: SwiftPM targets are single-language. Put Objective-C in its own target with a `include/` public headers directory, and have Swift modules depend on it.

## Splitting an oversized module

1. List its files by sub-area, plus who imports what (`references/audit.md`).
2. Pick the sub-area with the fewest inbound references and the clearest name.
3. Create the new module, move that sub-area, and make the old module depend on the new one (never the reverse).
4. Repoint consumers that only need the new module.
5. Repeat when there is a real reason to, not to hit a module count.

## Finishing

The migration is done when:

- the app target contains only the files in the table at the top;
- `swift test --package-path MyAppPackages` runs every unit test, and the app scheme has no unit-test action;
- CI runs the package job on package changes and the app build separately;
- `CLAUDE.md` lists every module, its purpose, and the graph.
