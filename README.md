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

Provides utilties for accessing Apple's `HealthKit` APIs.

- @kelvinkosbab TODO

## CoreStorage

Provides utilities for persistently storing data.

- @kelvinkosbab TODO

## CoreUI

Provides UIKit and SwiftUI helpers, components, and utilities.

- @kelvinkosbab TODO

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


