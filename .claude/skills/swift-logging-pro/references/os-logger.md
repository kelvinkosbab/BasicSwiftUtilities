# `os.Logger` Basics

## Why os.Logger

Apple's recommended logging API since iOS 14. Benefits over `print()`:

- **Performance** — log calls are extremely cheap; formatting is deferred until the log is read.
- **Privacy** — interpolated values default to private (redacted in production).
- **Structured filtering** — Console.app and `log` CLI can filter by subsystem/category/level.
- **Persistent** — logs are kept for a system-defined duration even across app launches.

## Creating a Logger

Always specify both `subsystem` and `category`:

```swift
import os

let logger = Logger(
    subsystem: "com.kozinga.MyApp",
    category: "Networking"
)
```

- **Subsystem**: reverse-DNS string identifying your app/library (typically the bundle ID).
- **Category**: a sub-component name (`Networking`, `Persistence`, `UI`, etc.).

This pair lets users filter logs in Console.app:

```
subsystem == "com.kozinga.MyApp" && category == "Networking"
```

## One Logger per category

Store a Logger as a `static let` per type or category to avoid recreation:

```swift
final class NetworkClient {
    private static let logger = Logger(
        subsystem: "com.kozinga.MyApp",
        category: "Networking"
    )

    func send(_ request: URLRequest) async throws {
        Self.logger.info("Sending request to \(request.url?.absoluteString ?? "<none>", privacy: .public)")
        // ...
    }
}
```

## Logger via a `Loggable` protocol

For library code, abstract the logger so consumers can plug in their own:

```swift
public protocol Loggable: Sendable {
    func log(_ message: String, level: LogLevel)
}

public struct SwiftLogger: Loggable {
    private let logger: os.Logger

    public init(subsystem: String, category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func log(_ message: String, level: LogLevel) {
        switch level {
        case .debug: logger.debug("\(message, privacy: .public)")
        case .info:  logger.info("\(message, privacy: .public)")
        case .error: logger.error("\(message, privacy: .public)")
        }
    }
}
```

This lets test code substitute a mock logger.

## Reading logs

In Console.app:

1. Connect a device or open the macOS console.
2. Filter by Subsystem.
3. Toggle "Action → Include Info Messages" / "Include Debug Messages" to see lower levels.

From the command line:

```bash
log stream --subsystem com.kozinga.MyApp --level debug
```

## Avoid `print()` in production

`print()` has no privacy markers, no levels, no filtering, and ends up in stdout where it can leak. Use `Logger` for everything in production code.

`print()` is fine in:

- Tests
- Scripts (`Package.swift` plugins, etc.)
- Development-only preview code
