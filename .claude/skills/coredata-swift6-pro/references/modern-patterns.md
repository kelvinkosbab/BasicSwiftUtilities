# Modern Core Data Patterns

## NSPersistentContainer is the entry point

Use `NSPersistentContainer` (or `NSPersistentCloudKitContainer` for CloudKit sync). Don't manage `NSPersistentStoreCoordinator` directly.

```swift
let container = NSPersistentContainer(name: "MyModel")
container.loadPersistentStores { description, error in
    if let error {
        fatalError("Failed to load store: \(error)")
    }
}
container.viewContext.automaticallyMergesChangesFromParent = true
```

## Use NSPersistentCloudKitContainer for CloudKit

For automatic iCloud sync:

```swift
let container = NSPersistentCloudKitContainer(name: "MyModel")
container.persistentStoreDescriptions.first?.cloudKitContainerOptions =
    NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.example.myapp")
```

Constraints with CloudKit:

- Never use `@Attribute(.unique)` (CloudKit doesn't support uniqueness constraints).
- All model properties must have default values or be optional.
- All relationships must be optional.
- No undo support.

## Fetch results

For SwiftUI lists, use `@FetchRequest`:

```swift
@FetchRequest(
    sortDescriptors: [SortDescriptor(\.createdAt, order: .reverse)]
)
private var items: FetchedResults<Item>
```

Use `SortDescriptor` (Swift) over `NSSortDescriptor` (Objective-C) for type safety.

For dynamic queries, build the request explicitly:

```swift
let request = Item.fetchRequest()
request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)]
request.predicate = NSPredicate(format: "category == %@", category)
let results = try viewContext.fetch(request)
```

## Counting without fetching

`fetchCount` is much faster than `fetch().count` when you only need the number:

```swift
let count = try viewContext.count(for: Item.fetchRequest())
```

## Predicate type safety

Prefer `#Predicate` macro (iOS 17+) over `NSPredicate` strings:

```swift
let predicate = #Predicate<Item> { item in
    item.category == "books" && item.year >= 2020
}
let request = Item.fetchRequest()
request.predicate = NSPredicate(predicate, in: viewContext)
```

`#Predicate` catches typos at compile time and supports proper Swift types.

## Batch operations

For bulk updates/deletes, use `NSBatchUpdateRequest` / `NSBatchDeleteRequest`:

```swift
let batchDelete = NSBatchDeleteRequest(fetchRequest: Item.fetchRequest())
batchDelete.resultType = .resultTypeObjectIDs
let result = try viewContext.execute(batchDelete) as! NSBatchDeleteResult

// Merge changes back into viewContext
let changes: [AnyHashable: Any] = [
    NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
]
NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
```

Batch operations bypass the validation and notification system — they're fast but require manual change merging.

## Codable transformers

To store custom types, use `NSSecureUnarchiveFromDataTransformer`:

```swift
@objc(MyTypeTransformer)
final class MyTypeTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass] { [MyType.self] }

    static func register() {
        let name = NSValueTransformerName(rawValue: String(describing: MyTypeTransformer.self))
        ValueTransformer.setValueTransformer(MyTypeTransformer(), forName: name)
    }
}
```

Then in the model, set the attribute type to "Transformable" with the transformer name.

For Codable types in modern code, prefer storing as JSON `Data`:

```swift
extension Item {
    var preferences: Preferences {
        get {
            guard let data = preferencesData else { return .default }
            return (try? JSONDecoder().decode(Preferences.self, from: data)) ?? .default
        }
        set {
            preferencesData = try? JSONEncoder().encode(newValue)
        }
    }
}
```

## Lightweight migrations

For most schema changes, enable lightweight migration:

```swift
let description = container.persistentStoreDescriptions.first!
description.shouldMigrateStoreAutomatically = true
description.shouldInferMappingModelAutomatically = true
```

Lightweight migration handles:

- Adding/removing entities, attributes, relationships.
- Renaming with `renamingIdentifier` set in the model.
- Type changes between compatible types.

For complex migrations, write a custom mapping model.

## Avoid the legacy NSManagedObjectModel(byMerging:) pattern

Don't merge multiple `NSManagedObjectModel`s — it's brittle and rarely needed. One model per persistent container.
