# ``CoreStorage``

Provides utilities for persistently storing data using CoreData and a lightweight disk-backed
key-value store.

## CoreData Utilities

This module simplifies working with Apple's CoreData framework. It provides protocols and
types that handle persistent store loading, object management, and change observation.

### Loading Your CoreData Store

Use ``PersistentDataContainer`` to load your app's CoreData persistent store on startup:

```swift
let container = try MyDataContainer(storeName: "MyModel", in: .main)
try await container.load()
```

### Observing Data Changes

``DataObserver`` listens for changes to the underlying CoreData store and notifies your app
when objects are inserted, updated, or deleted.

## Disk-Backed Key-Value Store

``DiskBackedJSONCodableStore`` provides a simple key-value store backed by JSON files on disk.
It conforms to the ``CodableStore`` protocol and supports any `Codable & Sendable` type.

```swift
let store = DiskBackedJSONCodableStore<UserSettings>(storeName: "settings")
try await store.set(value: settings, forKey: "current")
let saved = try await store.getValue(forKey: "current")
```

Use ``AnyCodableStore`` for type-erased access via ``CodableStore/eraseToAnyCodableStore()``.
