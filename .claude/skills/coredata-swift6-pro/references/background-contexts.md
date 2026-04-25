# Background Contexts

## When to use a background context

Use a background context when:

- Importing/processing large data sets that would block the main thread.
- Performing long-running fetches.
- Handling network responses that update Core Data.
- Running migrations or batch operations.

For small reads driven by UI, `viewContext` (on the main thread) is fine.

## Creating a background context

```swift
let bgContext = container.newBackgroundContext()
```

Each call creates a fresh context. Don't share background contexts across unrelated work.

For repeated background work, store one as a property:

```swift
@MainActor
final class DataImporter {
    let container: NSPersistentContainer
    private lazy var bgContext = container.newBackgroundContext()
}
```

## All work goes through `perform { }`

A background context's queue is private. **All access must happen inside a `perform` or `performAndWait` block:**

```swift
// ❌ Crash — accessing context outside its queue
let object = MyEntity(context: bgContext)
object.value = "foo"
try bgContext.save()

// ✅ Correct
try await bgContext.perform {
    let object = MyEntity(context: bgContext)
    object.value = "foo"
    try bgContext.save()
}
```

## perform vs performAndWait

| Method | Use for | Returns |
|--------|---------|---------|
| `perform { }` (closure) | Async dispatch | Void (returns immediately) |
| `perform { } async throws -> T` | Awaitable async work | The block's return value |
| `performAndWait { }` | Synchronous (blocks current thread) | Void |

Modern code uses the async version:

```swift
let count = try await bgContext.perform {
    try bgContext.count(for: MyEntity.fetchRequest())
}
```

## Merging changes back to viewContext

Background context changes don't automatically appear in `viewContext` unless configured:

```swift
container.viewContext.automaticallyMergesChangesFromParent = true
```

With this set, saves on background contexts trigger UI updates via `NSFetchedResultsController` or `@FetchRequest`.

## Don't pass NSManagedObjects between contexts

Each `NSManagedObject` belongs to a single context. To work with the same record across contexts, pass the `NSManagedObjectID`:

```swift
let objectID = await viewContext.perform {
    let object = try viewContext.fetch(...).first!
    return object.objectID
}

try await bgContext.perform {
    let object = try bgContext.existingObject(with: objectID) as! MyEntity
    object.value = "updated"
    try bgContext.save()
}
```

## Merge policies

When multiple contexts touch the same object, conflicts can arise. Set a merge policy on the context:

```swift
bgContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
```

Common policies:

- `NSErrorMergePolicy` (default) — throws on conflict.
- `NSMergeByPropertyObjectTrumpMergePolicy` — in-memory wins.
- `NSMergeByPropertyStoreTrumpMergePolicy` — store wins.
- `NSOverwriteMergePolicy` — in-memory overwrites.
- `NSRollbackMergePolicy` — discard in-memory changes on conflict.

## Saving up the parent chain

If you create a context with a parent (`bgContext.parent = viewContext`), saving the child only writes to the parent — you must save the parent to persist:

```swift
try await childContext.perform {
    try childContext.save()
}
try await viewContext.perform {
    try viewContext.save()
}
```

For most use cases, prefer `newBackgroundContext()` (which writes directly to the persistent store coordinator) over parent/child contexts.
