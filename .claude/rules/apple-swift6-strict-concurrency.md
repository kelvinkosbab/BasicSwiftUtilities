---
description: Enforce Swift 6.2 strict concurrency rules when writing or reviewing Swift code
globs: "**/*.swift"
---

# Swift 6.2 Strict Concurrency

This project uses `SWIFT_STRICT_CONCURRENCY = complete` and `.swiftLanguageMode(.v6)`. All `Sendable` violations are compile errors, not warnings.

## Core Rules

- Prefer `@MainActor` at the **type level** over annotating individual properties or methods.
- Never use `@unchecked Sendable` — redesign to avoid it.
- Avoid `DispatchQueue.main.async` — use structured concurrency (`Task`, `async`/`await`).
- Avoid global mutable state (`static var`) — use actor-isolated singletons or dependency injection.
- Never use `try!` or `force_try` — use `do/catch` with proper error handling and logging.

## Type Patterns

- **View models**: `@MainActor @Observable final class`
- **Service classes** (scanners, publishers): `@MainActor final class` — implicitly `Sendable`
- **Core Data types**: `@MainActor` since all access goes through `viewContext`
- **SwiftData types**: `@MainActor` for `PreferencesStore` and similar persistence wrappers
- **Value types** crossing isolation boundaries: must conform to `Sendable` explicitly

## Protocol Patterns

- `@MainActor` protocols inherit `AnyObject, Sendable`
- ObjC protocol conformances (`NetServiceDelegate`, `NetServiceBrowserDelegate`): use `@preconcurrency` on the conformance, not `nonisolated` methods

## Common Patterns

- `nonisolated let` for properties needed by `nonisolated` protocol requirements (e.g., `Identifiable.id`)
- `nonisolated(unsafe)` only for truly safe statics that can't satisfy the compiler
- `@preconcurrency` on ObjC protocol conformances and `EnvironmentKey` where the protocol predates concurrency
- When both sides of a delegate chain are `@MainActor`, call delegate methods directly — no `nonisolated` or `Task` hop needed

## SwiftUI-Specific

- In SwiftUI View body code, do **not** wrap `@State` mutations in `Task { @MainActor in }` — Views already run on the main actor
- Use `[weak self]` in `Task` closures that capture `self` with a delay (e.g., `Task.sleep`)
- Properties accessed from nonisolated contexts (like `UIDevice.current`) must be annotated with `@MainActor`
