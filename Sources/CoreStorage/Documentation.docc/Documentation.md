# ``CoreStorage``

Provides utilities for persistently storing data. This pacakge includes utilities for Apple's
`CoreData` as well as a custom `SQLite` implementation, ``CodableStore`` and
``DiskBackedJSONCodableStore``.

## `CoreData` Utilities

Notes:

`async/await` support

- Utilities for loading a `CoreData` persistent store.
- Utilities for listening to updates from a `CoreData` persistent store on either a main or
a background thread.
- Utilities for mapping `CoreData` object to a thread-safe `struct` and being able to query data
in a view's data model of those structs.
- Utilities for querying `CoreData` stores as well as utilities for creating listeners based on
a `Predicate`.

## Custom `SQLite` Utilities
- ``DiskBackedJSONCodableStore`` utility for creating a way to read and write to a simple `SQLite`
database. 
