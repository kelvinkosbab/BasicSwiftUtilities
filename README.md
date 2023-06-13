# BasicSwiftUtilities

This package provides basic utilities and APIs for an application running on Apple's platforms'.

Note: This pacakge is designed such that its only dependency is Apple's frameworks. 

Developed by Kelvin Kosbab
kelvin.kosbab@kozinga.net
https://kelvinkosbab.github.io/BasicSwiftUtilities

## Core

Provides basic utilities for an app running on Apple platforms.

### Logging

Defines a `Loggable` protocol and wraps Apple's native `os_log` and `os.Logger` APIs. These wrappers
Provide objects and methods for emitting logs that will censor sensitive and personal information
of the user in prod environments while not being sensored in testing and development environments.

Also, defines a `SubsystemCategoryLogger` object which will log messages to the system with
specified `subsystem` and `category` tags which can then be filtered for debugging.

### Concurrency

Defines helpers for more easily supporting `Void` continuations of async functions without the
annoying extra typing for methods that return `Void`.

Includes `Void` wrapper helpers for:
 - `withUnsafeThrowingContinuation`
 - `withUnsafeContinuation`
 - `withCheckedThrowingContinuation`
 - `withCheckedContinuation`

### Retry Utilities

Defines helpers for retrying operations which may fail and also define the `RetryStrategy` for
the retried operation.

### Long Running Tasks

Providees means to easily register tasks that should continue if the app enters the background. By
using the `LongRunningTaskOrchestrator:register` tasks can easily be declared to the OS and will be
given the opportunity to finish with helpful logging on the result of the background operation.

## CoreHealth

Provides utilties for accessing Apple's `HealthKit` APIs. These APIs wrap Apple's APIs to provide
useful ways to query data safely via units that each health biometric supports (`HealthKit`'s APIs
will crash the app if the trying to convert a biometric value to the wront unit which is not
an elegant way of handling this behavior).

- Utilities for authorizing health biometrics and also checking the authorization status
of health biometrics.
- Utilities for querying health biometrics with the desired units.
- Utilities to enable background delivery for specified health biometrics.
- Utilities to support Swift `async/await` for authorizations and queries.

## CoreStorage

Provides utilities for persistently storing data. This pacakge includes utilities for Apple's
`CoreData` as well as a custom `SQLite` implementation, `CodableStore`.

- Utilities for loading a `CoreData` persistent store.
- Utilities for listening to updates from a `CoreData` persistent store on either a main or
a background thread.
- Utilities for mapping `CoreData` object to a thread-safe `struct` and being able to query data
in a view's data model of those structs.
- Utilities for querying `CoreData` stores as well as utilities for creating listeners based on
a `Predicate`.
- `DiskBackedCodableStore` utility for creating a way to read and write to a simple `SQLite`
database. 

## CoreUI

Provides UIKit and SwiftUI helpers, components, and utilities.

- Font utilies and custom font registration

- SwiftUI components:
  - Activity indicator
  - Blurred view modifier
  - Button styles and view modifiers
  - Color utiliites
  - Core spacing and margins
  - Toasts
  
- UIKit components:
  - Base view controllers
  - Presentable API providing navigation helpers and utilities


