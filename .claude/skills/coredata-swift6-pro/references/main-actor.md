# `viewContext` and `@MainActor`

## viewContext is bound to the main queue

`NSPersistentContainer.viewContext` is created with `concurrencyType = .mainQueueConcurrencyType`. All synchronous access — fetching, reading attributes, saving — must happen on the main thread.

Under Swift 6 strict concurrency, this means **types that wrap `viewContext` should be `@MainActor`**.

## Mark Core Data types `@MainActor`

For types that hold or use a `viewContext`:

```swift
@MainActor
public final class ObjectStore {
    private let context: NSManagedObjectContext  // viewContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func fetch() throws -> [MyEntity] {
        try context.fetch(MyEntity.fetchRequest())  // ✅ on main thread
    }
}
```

Without `@MainActor`, the compiler will complain because `NSManagedObjectContext` is not `Sendable`.

## NSManagedObject is not Sendable

`NSManagedObject` and its subclasses are **not `Sendable`**. They have implicit thread affinity to their context's queue.

This means:

- ❌ Don't pass `NSManagedObject` instances across actor boundaries.
- ❌ Don't store them in `Sendable` value types.
- ❌ Don't capture them in `@Sendable` closures.

To pass an object reference across boundaries, use `NSManagedObjectID`:

```swift
@MainActor
func fetchOnMain() throws -> NSManagedObjectID {
    let object = try viewContext.fetch(...).first!
    return object.objectID  // ID is Sendable
}

// On a background context:
let bgContext = container.newBackgroundContext()
try await bgContext.perform {
    let object = try bgContext.existingObject(with: objectID)
    // ... use object on bgContext ...
}
```

## Tests using viewContext must be `@MainActor`

Sync tests that touch `viewContext` will fail under Swift 6 unless marked `@MainActor`:

```swift
// ❌ Will fail — runs off-main
@Test
func createObject() throws {
    let store = ObjectStore(context: viewContext)
    try store.create(...)
}

// ✅ Correct
@MainActor
@Test
func createObject() throws {
    let store = ObjectStore(context: viewContext)
    try store.create(...)
}
```

Apply `@MainActor` to the entire suite if all tests need it:

```swift
@MainActor
@Suite("ObjectStore")
struct ObjectStoreTests {
    @Test func create() throws { ... }
    @Test func update() throws { ... }
}
```

## Async tests don't need `@MainActor`

If a test uses `await` and works through a background context, it doesn't need `@MainActor`:

```swift
@Test
func backgroundCreate() async throws {
    let bgContext = container.newBackgroundContext()
    try await bgContext.perform {
        let object = MyEntity(context: bgContext)
        object.value = "foo"
        try bgContext.save()
    }
}
```

The `perform` block already provides isolation.

## Don't use `MainActor.run` to escape

If you find yourself wrapping Core Data calls in `MainActor.run`, that's a sign your type isn't isolated correctly. Mark the type or method `@MainActor` instead:

```swift
// ❌ Smell
func loadData() async {
    let items = await MainActor.run {
        try? viewContext.fetch(MyEntity.fetchRequest())
    }
    // ...
}

// ✅ Better
@MainActor
func loadData() {
    let items = try? viewContext.fetch(MyEntity.fetchRequest())
    // ...
}
```
