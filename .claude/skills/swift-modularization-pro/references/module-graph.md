# Module graph

## Layers and allowed edges

```
App target            @main, Info.plist, entitlements, AppShortcutsProvider
  └─ AppCore          root scene, routing, dependency wiring
       ├─ Features    one module per area (FeatureTasks, FeatureSettings)
       ├─ Intents     App Intents, entities, queries
       └─ Backends    umbrella + one implementation module per vendor
            │
            ▼  everything above may depend on everything below
DesignSystem · interface modules (XCore) · Domain (Models, Storage, Localization)
            │
            ▼
Core                  logging, utilities; no app-domain types
```

| From → To | Allowed? |
|---|---|
| Anything → Core | ✅ |
| Domain → Domain | ✅ when it stays acyclic (KozBon: `BonjourModels` → `BonjourStorage`, `BonjourLocalization`) |
| Feature → Domain, DesignSystem, interface modules | ✅ |
| Feature → Feature | ❌ move the shared piece down |
| Feature → concrete backend | ❌ depend on the interface or the umbrella. The exception is UI that is about a specific backend, such as a provider picker showing each provider's brand mark (KozBon's `BonjourUI` imports the provider modules for this). Keep those imports in one place. |
| Backend → interface module, Domain, Core | ✅ |
| Backend → Feature, AppCore | ❌ |
| DesignSystem → Domain models / view models | ❌ components take primitives and closures |
| Anything → AppCore | ❌ only the app target and extensions link it |
| Core → anything in the app | ❌ |

## Module kinds

- **Foundation (`Core`)**: logging (`Logger` categories), small utilities, dispatch helpers, and test support that every module uses. It knows nothing about the app's domain. Third-party foundation packages (KozBon's `Core` / `CoreUI` from BasicSwiftUtilities) sit beside it.
- **Domain**: `Models` (value types, IDs, domain errors), `Storage` (persistence and repositories; see `apple-repository-pattern.md`), `Localization` (the `Strings` facade and its catalog). These are the most widely imported modules, so keep them free of UI.
- **Feature**: one per user-facing area (`FeatureSettings`, `FeatureDiscover`). Each holds views, view models, and feature-local services. KozBon keeps all screens in one `BonjourUI` module; that's fine at its size. Split by feature once a UI module passes a few dozen files or two teams touch it.
- **Interface / implementation / umbrella**: the pattern for interchangeable backends. `XCore` holds the protocols and shared value types. `XApple`, `XAnthropic`, and so on each implement them and depend on `XCore` only. `X` is the umbrella that chooses between them at runtime and may `@_exported import XCore` so consumers write one import. Only the implementation modules import vendor SDKs.
- **Capability modules**: small modules a low layer needs without the domain, such as KozBon's `LocalNetworkMonitor`, which wraps `NWPathMonitor` and depends only on `Core`.
- **App Intents**: intents, entities, and queries in their own module so the app and an App Intents extension can share them. The `AppShortcutsProvider` stays in the app target.
- **Design system**: tokens, icons, styles, and shared components (see `swift-design-system-pro`).
- **`AppCore` umbrella**: the root `Scene`, top-level navigation, environment and dependency wiring, and app-level commands (`AppCommands` for macOS menus). It is the only module allowed to know every feature.

## Naming

- Use a shared prefix for app modules when the package also contains generic ones (`BonjourCore`, `BonjourModels`). Use plain names (`Core`, `Models`, `FeatureSettings`) when it doesn't.
- Name modules after what they own, not the layer alone. `Storage` is better than `Data2`, and `FeatureSettings` is better than `UI3`.
- Products mirror targets one-to-one, so `import X` always means the module directory `X/`.

## Granularity heuristics

Split a module when:

- it has **two reasons to change** owned by different people or features;
- part of it pulls a **heavy dependency** (a vendor SDK, a large framework) that the rest doesn't need;
- **another target** (widget, intents extension, watch app) needs part of it;
- incremental builds of it are slow enough to notice, typically past roughly 50–80 files of active code.

Merge or don't create a module when:

- it has a single consumer and no independent tests;
- it exists only to hold one protocol (put the protocol in the interface module it belongs to);
- splitting would force `public` on types that are really internal implementation details.

Start with `Core` + `AppCore` plus the obvious domain modules, and let real boundaries pull the rest apart. KozBon reached 15 modules by splitting when each of these pressures appeared, not up front.

## Extension targets

- Widgets, App Intents extensions, share extensions, and watch apps are **thin Xcode targets that link package products**: usually a domain module plus a small feature module made for them, never `AppCore`.
- An extension needing code that currently lives in a feature module is the signal to move that code down into a module both can link.
- Mind binary size and memory limits in extensions. Link only the products they need, which is another reason vendor SDKs stay in implementation modules.

## Worked example: a task app

| Module | Layer | Purpose | Depends on |
|---|---|---|---|
| `Core` | foundation | `Logger` categories, `Clock` injection, small utilities | — |
| `Models` | domain | `Task`, `Task.ID`, `TasksError` | Core |
| `Localization` | domain | `Strings` facade + `Localizable.xcstrings` | — |
| `Storage` | domain | `TasksRepository` protocol, SwiftData implementation, in-memory fake | Core, Models |
| `SyncCore` | interface | `SyncService` protocol, sync value types | Core, Models |
| `SyncCloudKit` | implementation | CloudKit-backed `SyncService` | SyncCore, Models, Core |
| `DesignSystem` | UI | tokens, `AppIcon`, styles, components | Core |
| `FeatureTasks` | feature | list + detail views and view models | Models, Storage, SyncCore, DesignSystem, Localization |
| `FeatureSettings` | feature | settings screens | Models, Storage, DesignSystem, Localization |
| `TaskIntents` | intents | `CompleteTaskIntent`, `TaskEntity` | Models, Storage |
| `AppCore` | umbrella | root scene, tab routing, wiring `SyncCloudKit` into `SyncCore` | all of the above |

The app target holds `TasksApp.swift` (`@main` returning `AppCoreScene()`), `TasksShortcuts.swift` (the `AppShortcutsProvider`), Info.plist, entitlements, assets, the privacy manifest, and its main-bundle catalogs. A widget target links `Models`, `Storage`, and `DesignSystem`.
