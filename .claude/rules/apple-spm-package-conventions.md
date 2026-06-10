---
description: Conventions for authoring Swift Package Manager Package.swift files — tool-version pinning, platforms, products, per-module folder layout, resources, modern features, dependency hygiene
globs: "Package.swift,**/Package.swift"
---

# Swift Package Manager: Package.swift Conventions

Authoring strategy for `Package.swift`. Complements the `swift-package-pro` skill (which reviews public API, module organization, and dependency hygiene) by covering the manifest itself — what to pin, where to declare platforms, how to lay out modules, and which modern SPM features to opt into.

> **Starter template:** [`templates/Package.template.swift`](../../templates/Package.template.swift) is a ready-to-edit `Package.swift` that uses the `makeTargets()` helper pattern below. For a new package, copy that file in instead of writing the manifest from scratch.

## Tool Version Pinning

```swift
// swift-tools-version: 6.0
import PackageDescription
```

- **Pin to the lowest tools version that has the features you use** — every developer building the package must have at least this Swift toolchain. Setting it too high blocks contributors on older Xcodes; setting it too low denies you newer manifest features.
- **Don't bump the tools version unless you actually adopt a feature gated behind it.** Cosmetic bumps for "latest" surprise contributors mid-PR.
- The first line is *not* a comment in the conventional sense — SPM parses it. It must be the first line, with exact spacing.

## Platforms

```swift
let package = Package(
    name: "MyPackage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    // ...
)
```

- **Always declare `platforms:`** for any package targeting Apple platforms — without it, SPM falls back to old defaults that won't have the APIs you use.
- **Pick minimums you actually support** — declaring `iOS(.v15)` when your code uses `iOS 17` APIs creates confusing build errors at consumer sites instead of clean ones at your site.
- **Drop a platform from the list only if every type and import would need to be platform-guarded.** Half-supported platforms (`#if !os(watchOS)` everywhere) make consumers' builds brittle.

## Products

```swift
products: [
    .library(name: "Core", targets: ["Core"]),
    .library(name: "CoreUI", targets: ["CoreUI"]),
    .executable(name: "my-cli", targets: ["MyCLI"]),
],
```

- **One product per logically separable feature** — bundling all internal modules into a single mega-product forces consumers to import everything.
- **Default to `.library(name:targets:)`** without specifying `type:` (the default is dynamic on Apple platforms with linker-driven dead-code stripping; consumers can request `.static` if they need it).
- **Don't expose internal-only modules as products.** Products are the package's public API surface; internal modules support targets but stay implicit.

## Per-Module Folder Layout

For a multi-module package, use the per-module directory convention with **flat `Sources/`** and `Tests/` inside each module folder (not nested under another `<ModuleName>/` directory):

```
MyPackage/
├── Package.swift
├── Core/
│   ├── Sources/
│   │   └── *.swift
│   └── Tests/
│       └── *.swift
├── CoreUI/
│   ├── Sources/
│   │   ├── Resources/       (if the module ships assets/strings)
│   │   └── *.swift
│   └── Tests/
│       └── *.swift
└── README.md
```

- **`{Module}/Sources/`** holds the source, **`{Module}/Tests/`** holds the tests. `path:` strings in target declarations match this layout 1:1 (`path: "\(name)/Sources"`, `path: "\(name)/Tests"`).
- **Don't pile every module's sources into a flat top-level `Sources/`** unless you have exactly one module. Discoverability degrades fast at 4+ modules.
- **`{Module}/` directory at the package root** keeps each module self-contained and shows up cleanly in Xcode's navigator.
- **Resources sit at `{Module}/Sources/Resources/`** when present — uniform across modules, so the manifest just toggles `hasResources: true` (see the helper above) without needing bespoke `[Resource]` arrays per module.

## `makeTargets()` Helper for Many Similar Modules

When 2+ modules share the same shape (paired source + test target, optional resources, uniform Swift settings), reduce duplication with a helper at the bottom of `Package.swift`. The canonical version lives in [`templates/Package.template.swift`](../../templates/Package.template.swift) — copy that file rather than rewriting the helper each project. Signature:

```swift
func makeTargets(
    name: String,
    dependencies: [Target.Dependency] = [],
    hasTests: Bool = true,
    hasResources: Bool = false,
    testDependencies: [Target.Dependency] = [],
    testResources: [Resource]? = nil
) -> [Target]
```

**Usage** — adding a new module is a two-line change (one `product:` line, one `+ makeTargets(...)` block):

```swift
targets:
    makeTargets(name: "Core")
    + makeTargets(name: "CoreUI", dependencies: ["Core"], hasResources: true)
    + makeTargets(name: "CoreStorage", dependencies: ["Core"], testResources: [.process("Resources")])
```

- **The helper is local to `Package.swift`** — *don't* try to share it across packages via SPM (you can't import code into the manifest). Each package gets its own copy of `makeTargets()` and `sharedSwiftSettings`.
- **`hasResources` follows a folder convention** — `{Module}/Sources/Resources/`. Keeping the on-disk layout uniform across modules means the manifest doesn't need bespoke `[Resource]` arrays per module.
- **`hasTests: false` is for declarative resource-only targets** (a target that just ships strings or data files). Default is `true` — a missing test target is a problem to fix, not a config to support.
- **`testDependencies` adds modules the tests need beyond the module-under-test** — typically test fixtures from sibling modules. The module itself is always injected via `.byName(name:)`.

## Resources

```swift
.target(
    name: "BonjourLocalization",
    dependencies: [],
    path: "BonjourLocalization/Sources/BonjourLocalization",
    resources: [
        .process("Localizable.xcstrings"),
        .process("Resources")
    ]
)
```

- **`.process(...)`** is the default — SPM compiles `.xcassets`, `.xcstrings`, `.storyboard`, etc. and namespaces resources for `Bundle.module` access.
- **`.copy(...)`** is for files SPM should *not* compile or rename (raw data files, fixtures with deliberate paths). Rare.
- **Always access resources via `Bundle.module`** in code (`Bundle.module.url(forResource:withExtension:)`) — never `Bundle.main` (which is the consumer's app bundle, not yours).
- **Core Data caveat:** SPM cannot compile `.xcdatamodeld` files via the CLI. Either ship the model as raw resources and build the `NSManagedObjectModel` programmatically (see `coredata-swift6-pro` skill), or require Xcode for the build path that needs it.

## Swift Settings

`swiftSettings:` on each target (or the `sharedSwiftSettings` constant in the template) controls language mode, concurrency strictness, upcoming-feature opt-ins, and per-platform / per-configuration build flags. Get this right once at the package level; per-target overrides should be rare and intentional.

### Language mode: Swift 5 vs Swift 6

```swift
.swiftLanguageMode(.v5)  // legacy compatibility — current and explicit
.swiftLanguageMode(.v6)  // strict concurrency, full Sendable enforcement
```

- **Default to `.v6`** for new packages and for code you're actively maintaining. The `apple-swift6-strict-concurrency.md` rule encodes what `.v6` enforces (Sendable checking, actor isolation, no `@unchecked Sendable` band-aids).
- **Stay on `.v5` only when you have a documented migration plan** to `.v6`. The cost compounds the longer you wait — new APIs, third-party packages, and async patterns increasingly assume `.v6`-style isolation.
- **Don't omit `.swiftLanguageMode(...)`** in a new package — letting it default to the tool-version's implicit mode means a future Swift bump silently changes your concurrency strictness. Pin it.
- **Per-target overrides are legitimate during migration:** keep the package at `.v6` and override one slow-moving target to `.v5` until it catches up. Document the override in a comment with a target removal date.

### Concurrency strictness under Swift 5 mode

Under `.v6`, strict concurrency is on, full stop. Under `.v5`, you can dial it in incrementally:

```swift
// Swift 5 mode, opt into strict concurrency progressively:
swiftSettings: [
    .swiftLanguageMode(.v5),
    .enableExperimentalFeature("StrictConcurrency"),
    // OR with the compiler flag form for older toolchains that lack the feature flag:
    // .unsafeFlags(["-strict-concurrency=complete"])
]
```

- **`StrictConcurrency` was experimental in Swift 5.6–5.10**, graduated to the default behavior in `.v6`. If your toolchain is recent and you're staying on `.v5`, prefer the feature flag over `-strict-concurrency=complete` — feature flags are designed to graduate without consumer changes.
- **Levels for the compiler flag** (Swift 5 mode only): `minimal` (just `Sendable` checks across actor boundaries), `targeted` (data-race-safety for marked declarations), `complete` (full enforcement, same as `.v6`'s default). Pick `complete` to make migration to `.v6` a no-op.
- **Don't mix experimental and graduated forms** — e.g., `enableExperimentalFeature("RegionBasedIsolation")` inside `.v6` mode does nothing (it's already on) and looks like cargo-culting in code review.

### Upcoming features worth opting into

The `[upcoming features](https://github.com/apple/swift-evolution/blob/main/proposals/0362-piecemeal-future-features.md)` system lets you opt into specific source-breaking improvements *before* the next Swift major. Common ones for app/library code:

```swift
swiftSettings: [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("InternalImportsByDefault"),  // imports are `internal` unless `public import`
    .enableUpcomingFeature("MemberImportVisibility"),    // tighten member visibility across module boundaries
    .enableUpcomingFeature("ExistentialAny"),            // require `any P` for protocol existentials
]
```

- **`InternalImportsByDefault`** — module imports are `internal` unless marked `public import`. Forces explicit re-exports; catches accidental public-API leaks where an `import` of a dependency module makes it part of your package's public surface.
- **`public import` for re-exported types only** — when a public function's signature uses a type from a dependency module (`func make() -> SomeKit.SomeType`), the import must be `public`. Plain `import` is internal.
- **`ExistentialAny`** is high-value but disruptive on existing codebases — it surfaces every place you've written `let value: Codable` (which now requires `any Codable`). Worth doing as a focused migration PR.
- **Don't blanket-enable every upcoming feature** — read the proposal first. Some have real ergonomic costs you may not want.
- **Use `enableUpcomingFeature` for proposals that have been accepted** and are slated for a future Swift major. Use `enableExperimentalFeature` for pre-acceptance experiments. They graduate from experimental → upcoming → default; track which bucket each feature is in.

### Per-platform and per-configuration conditionals

```swift
swiftSettings: [
    .swiftLanguageMode(.v6),
    // Warn-as-error only on platforms/configs where breaking the build is acceptable:
    .unsafeFlags(["-warnings-as-errors"], .when(configuration: .debug)),
    // Platform-specific define so you can `#if NETWORK_AVAILABLE` in source:
    .define("NETWORK_AVAILABLE", .when(platforms: [.iOS, .macOS, .visionOS])),
]
```

- **`.when(platforms:)`** narrows a setting to specific Apple platforms — useful for features that don't apply on watchOS / tvOS.
- **`.when(configuration:)`** scopes to `.debug` vs `.release`. Useful for debug-only diagnostics or `-warnings-as-errors` in CI builds.
- **`.define("SYMBOL")`** adds a `#if SYMBOL` guard you can use in source. Cleaner than `#if os(iOS) || os(macOS)` chains.
- **Don't conditionalize what doesn't need to vary** — every `.when(...)` is one more axis a future contributor has to think through. If the setting is uniform across configurations, leave it unconditional.

### What to avoid

- **`.unsafeFlags(...)` in a published library** — packages using it cannot be consumed as a dependency from a *release* of another package. Fine in apps and CLI tools; avoid in libraries you publish. If you need a flag that only `unsafeFlags` exposes, file a Swift evolution proposal or wrap behind a `.when(configuration: .debug)` so release builds don't carry it.
- **Mixing `enableExperimentalFeature` and `enableUpcomingFeature` for the same feature** — a feature lives in one bucket at a time. Mixing means one branch is dead code; the dead branch is the one you'll forget to remove.
- **Setting `swiftSettings` on each target individually when they're meant to be uniform** — drift creeps in. Define `sharedSwiftSettings` once, reference it from every target (see [`templates/Package.template.swift`](../../templates/Package.template.swift)).
- **`OTHER_SWIFT_FLAGS` from Xcode project settings leaking into SPM expectations** — Xcode and SPM have different flag surfaces. Don't copy-paste Xcode build settings into `unsafeFlags`; check what SPM's `SwiftSetting` API exposes first.
- **`-ld_classic` in `linkerSettings` / `unsafeFlags`** — Xcode 27 (Swift 6.4) **removed the `ld64` classic linker; `-ld_classic` is no longer accepted** and fails the link. If a package carried it as a workaround for an old linker bug, drop it — the modern linker is the only option now.
- **Enabling concurrency strictness only in tests** — tests built against `.v5` source code while the source target is `.v6` will surface false positives in test failures. Keep language mode uniform across source and test targets in the same module.

## Dependencies

```swift
dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
    .package(url: "https://github.com/apple/swift-async-algorithms", exact: "1.0.0")
],
```

- **`from:` (open-ended major version)** for libraries you trust to honor SemVer (Apple's own packages, well-maintained community libs).
- **`exact:`** for executables that must reproduce the same build, or for dependencies whose maintainers don't honor SemVer.
- **`branch:` / `revision:`** for development pins only — never ship a release with a branch dependency. Consumers can't predict when a branch moves under them.
- **Avoid transitive dependency duplication.** If `Core` depends on `swift-collections` and `CoreUI` does too, the version unifies via the package's top-level dependencies — declare it once at the top, then reference `.product(name: "Collections", package: "swift-collections")` from each target.

## `Package.resolved` Discipline

`Package.resolved` records the exact dependency versions SPM resolved at build time. Whether to commit it depends on what the package *is*:

- **App packages (executable, end-user product):** **commit it.** Build reproducibility matters — your CI and every contributor's machine should resolve to the same transitive versions. Without it, two builds of the same source can land on different dependency versions and one of them has a regression you can't reproduce.
- **Library packages (consumed as dependencies):** **gitignore it.** Consumers do their own dependency resolution against your `from:` / `exact:` constraints. Your `Package.resolved` is irrelevant to them — committing it just generates merge-conflict noise when you bump deps.

For a monorepo with both shapes: commit `Package.resolved` at the *app* package's root, gitignore at every *library* package's root. The `.gitignore` entries from the AppBootstrapAI bundle already exclude it; un-ignore it explicitly for app packages.

```
# In the app package's .gitignore — un-ignore Package.resolved:
!Package.resolved
```

Common pitfalls:
- **Library author commits `Package.resolved`** — consumer CI hits confusing resolution mismatches and the library author wonders why every release branch carries a merge conflict on this file. Gitignore it.
- **App author gitignores `Package.resolved`** — CI and a dev box silently resolve different versions; a regression slips through review because reviewers see different bytes than CI built. Commit it.

## Local Development with Path Overrides

When iterating on a sibling package without round-tripping through Git — a monorepo with two packages, or developing against a local copy of an external dependency — replace the URL-based dependency with a path-based one:

```swift
dependencies: [
    .package(path: "../my-sibling-package"),
    // .package(url: "https://github.com/me/my-sibling-package", from: "1.0.0"),  // shipped form
]
```

- **`.package(path: ...)` substitutes for the URL form entirely** — they're mutually exclusive. Comment the URL form back in when you tag a release.
- **Use relative paths** (`"../my-other-package"`) so the package builds for any contributor with the same monorepo layout. Absolute paths break for everyone but you.
- **Path-based dependencies don't appear in `Package.resolved`** — your local override has no effect on consumers fetching from Git.
- **Don't ship a release with a path-based dependency.** Consumers can't fetch a relative path. Either guard with CI (`grep -E '\.package\(path:' Package.swift && exit 1` in the release workflow), or maintain a separate release branch.
- **For modules in the same package**, just declare a target dependency by name — path overrides are for crossing *package* boundaries, not target boundaries.

Alternative for short-term experimentation: branch dependency (`.package(url: ..., branch: "feature-branch")`). Same release-time caveat — never ship a release that depends on a moving branch reference.

## Test Targets

```swift
.testTarget(
    name: "CoreTests",
    dependencies: ["Core"],
    path: "Core/Tests/CoreTests"
)
```

- **`@testable import Core`** in tests gives access to `internal` symbols. Use it for testing internals; use plain `import Core` to test the public API.
- **Test targets don't need to declare platforms separately** — they inherit the package's `platforms:`.
- **Don't use `.testTarget(...)` for UI tests** — UI tests need an app host and live in an `.xctestplan` outside SPM. Keep UI tests in the consumer Xcode project.

## Build Plugins

Build-tool plugins run during compilation (lint / format / codegen); command plugins run on demand via `swift package plugin`. Both attach to individual targets via `plugins:`:

```swift
.target(
    name: "Core",
    dependencies: [
        .product(name: "Collections", package: "swift-collections")
    ],
    path: "Core/Sources",
    plugins: [
        .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
    ]
)
```

And the matching package-level dependency:

```swift
dependencies: [
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.63.2")
]
```

- **Apply plugins per-target, not blanket-via-helper** — different modules may have legitimate reason to skip linting (legacy modules tolerating warnings the rest of the package treats as errors). The `makeTargets()` helper can take a `plugins:` parameter for cases where uniform application is right.
- **Pin plugin versions like any other dependency** — `from:` for SemVer-honoring plugins, `exact:` when the plugin tracks a specific toolchain.
- **Build-tool plugins (`.plugin(...)`) run at build time.** Compile-time failures (lint errors) fail the build. Use this for guardrails you want CI and every developer to hit.
- **Command plugins run only when invoked** (`swift package my-plugin`). Use for codegen / formatting / fixture regeneration that shouldn't gate the build.
- **Don't author plugins inside your library package** unless they're tightly scoped to it. Cross-package plugins belong in their own package so consumers can adopt them independently.

Common plugin packages:

- [`SwiftLintPlugins`](https://github.com/SimplyDanny/SwiftLintPlugins) — Realm's SwiftLint as a build-tool plugin (used by KozBon).
- [`swift-format`](https://github.com/apple/swift-format) — Apple's official formatter; can run as a build-tool or command plugin.
- [`swift-docc-plugin`](https://github.com/apple/swift-docc-plugin) — generate DocC archives via `swift package generate-documentation`.
- Custom codegen plugins for projects with schemas (GraphQL, Protobuf, SourceKit-Stencil).

## Common Pitfalls

- **Missing `platforms:`** — falls back to ancient defaults; APIs you use aren't available; build fails at consumer sites with cryptic errors.
- **Path mismatches** — `path:` strings that don't reflect on-disk reality silently exclude sources. SPM doesn't validate paths until build time.
- **`.copy(...)` when `.process(...)` was meant** — `.copy` ships the file verbatim with no compilation. `.xcassets` copied won't work.
- **Bundle.main vs Bundle.module** — using `Bundle.main` to load a packaged resource works in single-target tests but breaks the moment a consumer app uses the package.
- **`unsafeFlags(...)`** — disqualifies the package from being a dependency of other published packages. Reserve for executables and CLIs, never libraries.
- **Branch dependencies in `from:` ranges** — accidentally pinning to a branch via `from: "0.0.0-pre.1"` etc. Set explicit `branch:` if you mean it, otherwise prefer tagged releases.
- **`@_implementationOnly import` after enabling `InternalImportsByDefault`** — the new feature replaces the old underscore-prefix attribute; don't mix.
- **Duplicate platform spelling** — `.iOS(.v17)` and `.macOS("13.0")` mixing literal and shorthand forms. Pick one form per package.

## Patterns to Follow

The canonical version of this pattern lives in [`templates/Package.template.swift`](../../templates/Package.template.swift). Abridged here for reference:

```swift
// swift-tools-version: 6.0
import PackageDescription

let sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("InternalImportsByDefault")
]

func makeTargets(
    name: String,
    dependencies: [Target.Dependency] = [],
    hasTests: Bool = true,
    hasResources: Bool = false,
    testDependencies: [Target.Dependency] = [],
    testResources: [Resource]? = nil
) -> [Target] {
    var targets: [Target] = [
        .target(
            name: name,
            dependencies: dependencies,
            path: "\(name)/Sources",
            resources: hasResources ? [.process("Resources")] : nil,
            swiftSettings: sharedSwiftSettings
        )
    ]
    if hasTests {
        targets.append(
            .testTarget(
                name: "\(name)Tests",
                dependencies: [.byName(name: name)] + testDependencies,
                path: "\(name)/Tests",
                resources: testResources,
                swiftSettings: sharedSwiftSettings
            )
        )
    }
    return targets
}

let package = Package(
    name: "MyPackage",
    platforms: [.iOS(.v17), .macOS(.v14), .tvOS(.v17), .watchOS(.v10), .visionOS(.v1)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "CoreUI", targets: ["CoreUI"]),
        .library(name: "CoreStorage", targets: ["CoreStorage"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0")
    ],
    targets:
        makeTargets(
            name: "Core",
            dependencies: [.product(name: "Collections", package: "swift-collections")]
        )
        + makeTargets(
            name: "CoreUI",
            dependencies: ["Core"],
            hasResources: true   // pulls CoreUI/Sources/Resources/ automatically
        )
        + makeTargets(
            name: "CoreStorage",
            dependencies: ["Core"],
            testResources: [.process("Resources")]
        )
)
```

Adding `CoreNetworking` is now a **two-line change**: a new `.library(name: "CoreNetworking", targets: ["CoreNetworking"])` in `products:`, and a new `+ makeTargets(name: "CoreNetworking", dependencies: ["Core"])` block in `targets:`. The Swift settings, path conventions, and test-target wiring all come for free.
