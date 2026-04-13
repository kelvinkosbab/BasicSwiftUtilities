# CLAUDE.md

## Project Overview

BasicSwiftUtilities is a Swift 6 package providing foundational utilities for Apple platforms — logging, retry strategies, persistent storage, SwiftUI components, and UIKit helpers.

## Build & Run

```bash
# Build
swift build

# Run tests
swift test

# Build for iOS Simulator
xcodebuild build-for-testing \
  -scheme BasicSwiftUtilities \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -skipPackagePluginValidation

# Test on iOS Simulator
xcodebuild test \
  -scheme BasicSwiftUtilities \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -skipPackagePluginValidation
```

## Architecture

- **Swift 6** with strict concurrency (`.swiftLanguageMode(.v6)`) and `InternalImportsByDefault`
- **Multi-platform**: iOS 17+, macOS 14+, tvOS 17+, watchOS 10+, visionOS 1+
- **No external dependencies** — all modules are self-contained
- **Per-module directory layout**: `{ModuleName}/Sources/` and `{ModuleName}/Tests/`
- **`makeTargets()` helper** in `Package.swift` reduces boilerplate for target definitions

## Modules

| Module | Purpose | Key Types |
|--------|---------|-----------|
| **Core** | Logging, retry strategies, long-running tasks | `Loggable`, `SwiftLogger`, `asyncRetry`, `LongRunningTaskOrchestrator` |
| **CoreUI** | SwiftUI components and utilities | `Spacing`, `CircleImage`, `ToastApi`, `HexColor`, `Color.hex()` |
| **CoreUIKit** | UIKit helpers and view controller utilities | `BaseHostingController`, `PresentableController`, `FontRegistrar`, `UIColor.hex()` |
| **CoreStorage** | CoreData and file-backed persistence | `PersistentDataContainer`, `ObjectStore`, `DataObserver`, `DiskBackedJSONCodableStore` |
| **RunMode** | Runtime mode detection | `RunMode` |

### Dependency Graph

```
CoreUIKit → CoreUI
CoreStorage → Core
Core, CoreUI, RunMode → (no internal dependencies)
```

## Code Conventions

- Use `// MARK: -` section headers to organize code within files
- One type per file, feature-based folder organization
- 4-space indentation (no tabs)
- Use `public import` only for frameworks whose types appear in public API signatures; use plain `import` for internal-only usage
- `#if !os(watchOS)` / `#if !os(macOS)` guards for platform-specific code
- Use `#Preview` macro for previews, not the legacy `PreviewProvider` protocol

## Swift 6 Strict Concurrency

### Core Rules

- All `Sendable` violations are compile errors, not warnings
- Prefer `@MainActor` at the **type level** over annotating individual properties or methods
- Never use `@unchecked Sendable` — redesign to avoid it
- Avoid `DispatchQueue.main.async` — use structured concurrency (`Task`, `async`/`await`)
- Avoid global mutable state (`static var`) — use actor-isolated singletons or dependency injection

### Classes

- **Observable classes**: `@MainActor @Observable final class` (or `@MainActor class` with `ObservableObject` for legacy toast system)
- **Service classes**: `@MainActor final class` — implicitly `Sendable`
- **Core Data** types: `@MainActor` since all access goes through `viewContext`

### Protocols

- `@MainActor` protocols inherit `AnyObject, Sendable`
- Use `@preconcurrency` on ObjC protocol conformances, not `nonisolated` methods

### Value Types

- Structs and enums crossing isolation boundaries must conform to `Sendable` explicitly

## Testing

- **Framework**: Swift Testing (`@Test`, `@Suite`, `#expect`)
- **Naming**: `<TypeName>Tests.swift` (e.g., `RetryTests.swift`)
- **`@MainActor` tests**: Use `@MainActor` on the test method when testing `@MainActor`-isolated types (especially CoreData `viewContext` tests)
- **CoreData tests**: Use programmatic `NSManagedObjectModel` construction (not `.xcdatamodeld` bundles) since SPM cannot compile `.momd` files
- **CoreData test isolation**: Use `NSInMemoryStoreType` for load tests
- **Cross-module testing**: Use `@testable import <Module>` to access internal types

## CI / GitHub Actions

| Workflow | Trigger | What it does |
|----------|---------|-------------|
| **CI** (`swift.yml`) | Push + PR to main | Build + test on macOS and iOS Simulator |
| **Nightly** (`nightly.yml`) | Weekly Sunday + manual | Same as CI, for detecting upstream breakage |

All workflows use `macos-15` runner with Xcode 16.3 and concurrency groups.

## Important Gotchas

- **CoreData `.momd` in SPM**: SPM cannot compile `.xcdatamodeld` files. Tests must build `NSManagedObjectModel` programmatically (see `CoreStorage/Tests/Utilities/KeyValue.swift`).
- **`viewContext` is main-queue**: All synchronous CoreData tests using `viewContext` must be `@MainActor`.
- **Platform guards**: CoreUIKit is UIKit-only (`#if !os(macOS)`). Many CoreUI views exclude watchOS. Always check platform availability.
- **`InternalImportsByDefault`**: When adding new source files with public API, use `public import` for frameworks whose types appear in public signatures. Plain `import` is internal-only.
