# ``Core``

Provides basic utilities for an app running on Apple platforms.

## Logging

Defines a ``Loggable`` protocol and wraps Apple's native `os.Logger` via ``SwiftLogger``.
These wrappers provide objects and methods for emitting logs that censor sensitive and personal
information in production environments while remaining visible in development.

``Logger`` is a convenience wrapper around ``SwiftLogger``. The level and category are
recorded as `os.Logger` metadata, so Console.app and the `log` CLI can filter by them
natively:

```swift
let logger = Logger(subsystem: "com.myapp", category: "Networking")
logger.info("Request sent")
// Console shows: "Info  Networking  Request sent"
```

## Retry Utilities

Defines helpers for retrying operations that may fail. These utilities support configurable
delay strategies such as exponential backoff, linear backoff, and constant delays.
See ``RetryStrategy`` for specific details.

- ``retry(maxAttempts:strategy:retryIf:block:)`` — Synchronous retry with configurable strategy.
- ``asyncRetry(max:strategy:retryIf:block:)`` — Async retry supporting Swift's `async/await`.

## Long Running Tasks

``LongRunningTaskOrchestrator`` provides a simple way to register tasks that should continue
if the app enters the background. Tasks are declared to the OS and will be given the opportunity
to finish with helpful logging on the result of the background operation.
