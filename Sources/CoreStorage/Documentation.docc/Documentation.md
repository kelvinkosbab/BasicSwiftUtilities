# ``CoreStorage``

Provides utilities for persistently storing data. This pacakge includes utilities for Apple's
`CoreData` as well as a custom `SQLite` implementation, ``CodableStore`` ([link](../CodableStore/CodableStore.swift)) and
``DiskBackedJSONCodableStore`` ([link](../CodableStore/DiskBackedJSONCodableStore.swift)).

## `CoreData` Utilities

`CoreData` is a very dense libary to get into and utilize at a high level. This package aims to
make it easier to utilize all the benefits of `CoreData` while mitigating the risks of managing
the data store directly. All that is required is to crate the `CoreData` model for your app,
create `struct` objects which mirror the `NSManagedObject` classes, and then conform your app
objects to ``ManagedObjectAssociated`` ([link](../CoreData/Types.swift)) and ``StructConvertable`` ([link](../CoreData/Types.swift)). This will allow you to create
data store objects which can create, update, and delete objects without having to manage any
`CoreData` specifics.

To make things easier, this API gives consumers the abilty to only specify thread-safe `struct`
objects for creating or updating objects and provides simple APIs for fetching and deleting
objects by their unique identifier. Consumers will never interact with the underlyihng `CoreData`
API.

Additionally consumers will have the ability to customize which `NSManagedObjectContext` they
wish operations to execute on giving the ability to perform operations on the main or background
thread as well as giving flexibility for how any custom context object interacts with other
`CoreData` context.

This API also provides Swift's `async/await` support for iOS 15.0, macOS 12.0, tvOS 15.0,
and watchOS 8.0.

### Loading your app's `CoreData` store

On app startup it is recommended to load your app's `CoreData` store as soon as possible. If the
store is not loaded the app may perform in unpredictable ways. This API provides mechanisms for
utilizing Swift's `async/await` operations to wait to perform important app operations until your
app's data stores have been loaded. See ``ManagedObjectContainer`` [link](../CoreData/ManagedObjectContainer.swift) for details.

Loading your `CoreData` store is as easy as this:

```swift
let dataStore = AppCoreDataStore()
await dataStore.configure() 
```

### Managing objects in your app's `CoreData` store

To manage objects in your `CoreData` store see ``ManagedObjectStore`` [link](../CoreData/ManagedObjectStore.swift). This protocol provides APIs
for creating, updating, and deleting objects of a certain type in the data store. Once defined
the data store provides useful utilites making it easy to manage data in your app. For example

```swift
let dataContainer = YourAppDataContainer()
let store = OneObjectDataStore(context: dataContainer.context)
let object = store.fetchOne(id: "objectID")
```

#### Utilizing `CoreData` main and private data queues

Core Data is designed to work in a multithreaded environment. However, not every object under the
Core Data framework is thread safe. To use Core Data in a multithreaded environment, ensure that:

- Managed object contexts are bound to the thread (queue) that they are associated with upon initialization.
- Managed objects retrieved from a context are bound to the same queue that the context is bound to.

Core data private queues are useful for executing `CoreData` database operations on a private queue.
To utilize private managed object queues for a ``ManagedObjectStore`` type simply initialize the store
with a `NAManagedObjectContext` set with a concurrency type of `.privateQueueConcurrencyType`.

Creating this kind of context can be done in two ways (be sure to set the private context's `parent`
to the app managed object store's primary context''):
```swift
let appCoreDataContainer = YourAppManagedObjectStore.shared
let privateQueueContext = appCoreDataContainer.newBackgroundContext()
privateQueueContext.parent = appCoreDataContainer.context

- or -

let appCoreDataContainer = YourAppManagedObjectStore.shared
let privateQueueContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
privateQueueContext.parent = appCoreDataContainer.context
```

For more information see [Apple's documentation](https://developer.apple.com/documentation/coredata/using_core_data_in_the_background).

### Listening to updates to the `CoreData` store

App's often have to react to when data updates to keep the UI/UX up to date. The ``DataObserver``
([link](../CoreData/DataObserver.swift)) class provides ways to actively listen for updates to the
underlying data store when updates happen.

## Custom Lightweight `SQLite` Utilities

``DiskBackedJSONCodableStore`` ([link](../CodableStore/DiskBackedJSONCodableStore.swift)) provides a
simple API for storing and accessing persistent data backed by a `SQLite` database. This database
provides a key-value API making it easy for lightweight and fast operations for querying or
setting persistent data. 

### ``CodableStore``

The ``DiskBackedJSONCodableStore`` ([link](../CodableStore/DiskBackedJSONCodableStore.swift)) provides a simple
and lightweight key-value store. When creating a ``DiskBackedJSONCodableStore`` you can specify the type of
data to be persisted, being bound by the `Codable` protocol.
