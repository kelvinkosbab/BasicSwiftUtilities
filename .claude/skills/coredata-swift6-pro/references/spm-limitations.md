# SPM Limitations with Core Data

## SPM cannot compile `.xcdatamodeld`

The Swift Package Manager (`swift build`, `swift test`) **cannot compile `.xcdatamodeld` files into `.momd` bundles**. Only Xcode (`xcodebuild`) can run the `momc` compiler.

### What this means in practice

If your package contains `MyModel.xcdatamodeld` and you try to load it with:

```swift
let url = Bundle.module.url(forResource: "MyModel", withExtension: "momd")!  // ❌ nil under swift test
let model = NSManagedObjectModel(contentsOf: url)!
```

This will work under `xcodebuild test` (which compiles the model) but **fail under `swift test`** (because no `.momd` exists in `Bundle.module`).

## Workaround 1: Build the model programmatically

Construct your `NSManagedObjectModel` in code. This works under both `swift test` and `xcodebuild test`:

```swift
func makeKeyValueManagedObjectModel() -> NSManagedObjectModel {
    let identifierAttribute = NSAttributeDescription()
    identifierAttribute.name = "identifier"
    identifierAttribute.attributeType = .stringAttributeType
    identifierAttribute.isOptional = true

    let valueAttribute = NSAttributeDescription()
    valueAttribute.name = "value"
    valueAttribute.attributeType = .stringAttributeType
    valueAttribute.isOptional = true

    let entity = NSEntityDescription()
    entity.name = "KeyValueManagedObject"
    entity.managedObjectClassName = "KeyValueManagedObject"
    entity.properties = [identifierAttribute, valueAttribute]

    let model = NSManagedObjectModel()
    model.entities = [entity]
    return model
}
```

Pros:

- Works in any test environment.
- Single source of truth — model and code are in sync (unlike `.xcdatamodeld` which is a separate XML file).
- Easy to add migrations programmatically.

Cons:

- Verbose for large schemas.
- No visual editor.

## Workaround 2: Test only with xcodebuild

If you keep `.xcdatamodeld`, mark Core Data tests as `xcodebuild`-only and skip them under `swift test`:

```swift
@Suite(.disabled(if: ProcessInfo.processInfo.environment["CI_SPM_ONLY"] != nil))
struct CoreDataTests { ... }
```

Pros:

- Visual model editor in Xcode.
- Migrations are auto-detected.

Cons:

- Tests can't run via `swift test` (slower CI, no Linux support).
- Two-step setup.

## In-memory store for test isolation

Regardless of which workaround, use `NSInMemoryStoreType` for tests so each test gets a clean store:

```swift
let description = NSPersistentStoreDescription()
description.type = NSInMemoryStoreType
container.persistentStoreDescriptions = [description]
```

Without this, tests share the on-disk SQLite store and pollute each other.

## Bundle.module gotchas

`Bundle.module` is auto-generated only in modules that declare resources. Common mistakes:

- Forgetting `resources: [.process("Resources")]` on the target.
- Putting resources outside the declared `resources` paths.
- Trying to use `Bundle.module` from a target that has no resources (the symbol won't exist).

## When .xcdatamodeld is unavoidable

If your model is large or you need versioned migrations:

1. Keep `.xcdatamodeld` in the package's source tree.
2. Build a programmatic shadow model for `swift test`.
3. Use the real `.xcdatamodeld` when running via Xcode.
4. Document the discrepancy in your CLAUDE.md / README.

The key insight: SPM tests and Xcode tests should both be possible, even if they go through different paths.

## Real-world example

See `CoreStorage/Tests/Utilities/KeyValue.swift` in this package — it builds the model programmatically for `swift test` compatibility.
