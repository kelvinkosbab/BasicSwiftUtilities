# ``Core``

Provides basic utilities for an app running on Apple platforms.

## Logging

Defines a ``Loggable`` ([link](../Logging/Loggable.swift)) protocol and wraps Apple's native `os_log` ``LoggableOSLog`` ([link](../Logging/LoggableOSLog.swift)) and
`os.Logger` ``SwiftLogger`` ([link](../Logging/SwiftLogger.swift)) APIs. These wrappers provide objects and methods for emitting
logs that will censor sensitive and personal information of the user in prod environments while
not being sensored in testing and development environments.

Also, defines a ``SubsystemCategoryLogger`` ([link](../Logging/SubsystemCategoryLogger.swift)) object which will log messages to the system with
specified `subsystem` and `category` tags which can then be filtered for debugging.

## Concurrency

Defines helpers for more easily supporting `Void` continuations of async functions without the
annoying extra typing for methods that return `Void`.

Includes `Void` wrapper helpers for:
- `withUnsafeThrowingContinuation` --> ``withUnsafeThrowingVoidContinuation(_:)``
- `withUnsafeContinuation` --> ``withUnsafeThrowingVoidContinuation(_:)``
- `withCheckedThrowingContinuation` --> ``withUnsafeThrowingVoidContinuation(_:)``
- `withCheckedContinuation` --> ``withCheckedThrowingVoidContinuation(_:)``

See [implementation details here](../Concurrency).

### Retry Utilities

Defines helpers for retrying operations which may fail. These utilities support strategies for
the delay between retries such as `exponential` and  `constant`. See ``RetryStrategy`` for
specific details.

For details see ``retry(maxAttempts:strategy:block:)`` ([link](../Retry/Retry.swift)) and ``asyncRetry(max:strategy:retryIf:block:)`` ([link](../Retry/AsyncRetry.swift))
which supports Swift's `async/await` operations.

### Long Running Tasks

Providees means to easily register tasks that should continue if the app enters the background. By
using the ``LongRunningTaskOrchestrator`` ([link](../LongRunningTaskOrchestrator.swift)) tasks can easily be declared to the OS and will be
given the opportunity to finish with helpful logging on the result of the background operation.
