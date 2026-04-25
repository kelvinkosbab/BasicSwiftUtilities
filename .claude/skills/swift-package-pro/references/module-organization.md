# Module Organization

## Per-module directory layout

Prefer the per-module layout over the flat `Sources/{Name}` and `Tests/{Name}Tests` layout:

```
PackageRoot/
    Package.swift
    Core/
        Sources/
        Tests/
    CoreUI/
        Sources/
        Tests/
```

This scales better than:

```
PackageRoot/
    Package.swift
    Sources/
        Core/
        CoreUI/
    Tests/
        CoreTests/
        CoreUITests/
```

In `Package.swift`, set `path:` explicitly:

```swift
.target(
    name: "Core",
    path: "Core/Sources"
)
.testTarget(
    name: "CoreTests",
    dependencies: ["Core"],
    path: "Core/Tests"
)
```

## Helper functions for boilerplate reduction

Define a `makeTargets()` helper to avoid repeating target definitions:

```swift
let sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("InternalImportsByDefault")
]

func makeTargets(
    name: String,
    dependencies: [Target.Dependency] = [],
    hasTests: Bool = true,
    testResources: [Resource]? = nil
) -> [Target] {
    var targets: [Target] = [
        .target(
            name: name,
            dependencies: dependencies,
            path: "\(name)/Sources",
            swiftSettings: sharedSwiftSettings
        )
    ]
    if hasTests {
        targets.append(
            .testTarget(
                name: "\(name)Tests",
                dependencies: [.byName(name: name)],
                path: "\(name)/Tests",
                resources: testResources,
                swiftSettings: sharedSwiftSettings
            )
        )
    }
    return targets
}
```

## Dependency graph hygiene

- Keep the dependency graph acyclic — circular dependencies between modules are a smell.
- Foundational modules (utilities, models) should depend on nothing internal.
- UI modules depend on model modules, never the reverse.
- If two modules need to share types, those types belong in a third lower-level module.

Document the graph in your `CLAUDE.md` or `README.md`:

```
CoreUIKit → CoreUI
CoreStorage → Core
Core, CoreUI, RunMode → (no internal dependencies)
```

## Single responsibility per module

Each module should answer one question. Flag modules that mix unrelated concerns:

- ✅ `Core` — logging + retries + long-running tasks (all are foundational utilities)
- ❌ `Utilities` — logging + networking + persistence + UI (too broad)

If a module's name needs an "and" to describe it, consider splitting it.
