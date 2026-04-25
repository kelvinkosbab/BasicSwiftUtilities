---
name: coredata-swift6-pro
description: Reviews Core Data code for Swift 6 strict concurrency compliance, modern context usage, and SPM compatibility. Use when reading, writing, or reviewing Core Data code under Swift 6.
license: MIT
metadata:
  author: Kelvin Kosbab
  version: "1.0"
---

Review Core Data code for Swift 6 concurrency correctness, modern API usage, and SPM compatibility. Report only genuine problems - do not nitpick or invent issues.

Review process:

1. Validate `viewContext` access is `@MainActor`-isolated using `references/main-actor.md`.
1. Check background context usage with `perform`/`performAndWait` using `references/background-contexts.md`.
1. Verify SPM compatibility for `.xcdatamodeld` bundling using `references/spm-limitations.md`.
1. Check for modern persistent container patterns and fetch result types using `references/modern-patterns.md`.
1. Flag direct cross-context object passing (must pass `NSManagedObjectID` instead).

If doing a partial review, load only the relevant reference files.


## Core Instructions

- Target Swift 6 with strict concurrency. Core Data + Swift 6 has specific rules that must be followed.
- `viewContext` is bound to the main queue — all synchronous access must be `@MainActor` or wrapped in `MainActor.run`.
- `NSManagedObject` subclasses are NOT `Sendable`. Never pass them across isolation boundaries — use `NSManagedObjectID` instead.
- All background context work goes through `context.perform { }` (async) or `context.performAndWait { }` (sync).
- For SPM packages, `.xcdatamodeld` cannot be compiled to `.momd` by `swift build` — only Xcode can. Tests run via `swift test` must build `NSManagedObjectModel` programmatically.
- Use `NSPersistentContainer` (or `NSPersistentCloudKitContainer`), not the deprecated `NSPersistentStoreCoordinator` directly.
- Prefer `.viewContext.automaticallyMergesChangesFromParent = true` so background changes propagate.
- For tests, use `NSInMemoryStoreType` so each test has an isolated store.


## Output Format

Organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated.
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary of the most impactful changes to make first.

Example output:

### CoreStorage/Tests/ObjectStoreTests.swift

**Line 23: Sync `viewContext` test missing `@MainActor` — will fail under Swift 6 strict concurrency.**

```swift
// Before
@Test func createUpdateDeleteObject() throws {
    let store = ObjectStore(...)
    try store.create(...)
}

// After
@MainActor @Test func createUpdateDeleteObject() throws {
    let store = ObjectStore(...)
    try store.create(...)
}
```

**Line 45: Background context work missing `perform { }` block.**

```swift
// Before
let bgContext = container.newBackgroundContext()
let object = MyObject(context: bgContext)
object.value = "foo"
try bgContext.save()

// After
let bgContext = container.newBackgroundContext()
try await bgContext.perform {
    let object = MyObject(context: bgContext)
    object.value = "foo"
    try bgContext.save()
}
```

### CoreStorage/Tests/Utilities/KeyValue.swift

**Line 14: Test relies on `Bundle.module` for `.momd` — will fail under `swift test`.**

```swift
// Before
self.init(storeName: "MyModel", in: .module)

// After
let model = makeKeyValueManagedObjectModel()
self.init(storeName: "MyModel", managedObjectModel: model)
```

### Summary

1. **Concurrency (high):** 4 sync `viewContext` tests missing `@MainActor` annotation.
2. **SPM compatibility (high):** Test container relies on `Bundle.module` for `.momd` — must build model programmatically.
3. **Concurrency (medium):** Background context work outside `perform { }` block on line 45.

End of example.


## References

- `references/main-actor.md` — `viewContext` main-queue binding, `@MainActor` test patterns, isolation rules.
- `references/background-contexts.md` — `perform`/`performAndWait`, `newBackgroundContext`, async wrappers, merge policies.
- `references/spm-limitations.md` — `.xcdatamodeld` compilation, `Bundle.module` issues, programmatic `NSManagedObjectModel`.
- `references/modern-patterns.md` — `NSPersistentContainer`, fetch results, Codable transformers, CloudKit container.
