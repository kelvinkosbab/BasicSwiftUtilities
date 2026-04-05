# BasicSwiftUtilities

A Swift 6 package providing foundational utilities for Apple platforms — logging, retry strategies,
persistent storage, SwiftUI components, and UIKit helpers.

Developed by Kelvin Kosbab
kelvin.kosbab@kozinga.net
https://kelvinkosbab.github.io/BasicSwiftUtilities

## Modules

| Module | Description |
|--------|-------------|
| **Core** | Logging, retry strategies, and background task orchestration |
| **CoreUI** | SwiftUI components, view modifiers, color utilities, and toast system |
| **CoreUIKit** | UIKit view controllers, presentation helpers, color utilities, and font registration |
| **CoreStorage** | CoreData helpers and a lightweight disk-backed key-value store |
| **RunMode** | Detect whether the current process is the main app, unit tests, or UI tests |

**Platform Support:**
- iOS 17.0
- macOS 14.0
- tvOS 17.0
- watchOS 10.0
- visionOS 1.0

**Swift Version:** 6.0 with strict concurrency

## Package Structure

Each module is organized with colocated sources and tests:

```
BasicSwiftUtilities/
    Package.swift
    Core/
        Sources/
        Tests/
    CoreUI/
        Sources/
        Tests/
    CoreUIKit/
        Sources/
    CoreStorage/
        Sources/
        Tests/
    RunMode/
        Sources/
        Tests/
```

## Core

Provides logging, retry strategies, and background task management.

- **Logging** — `Logger` wraps Apple's `os.Logger` with category-tagged, privacy-aware log
  messages. See the `Loggable` protocol for the logging interface.
- **Retry** — `retry()` and `asyncRetry()` support configurable backoff strategies (exponential,
  linear, constant, custom) with jitter. See `RetryStrategy`.
- **Background Tasks** — `LongRunningTaskOrchestrator` registers tasks that should continue
  when the app enters the background.

For details see [Core's Documentation](./Core/Sources/Documentation.docc/Documentation.md).

### CoreUI

SwiftUI components, modifiers, and utilities.

- **Toast System** — `ToastApi` with configurable position, shape, and animation style
- **Color Utilities** — Define colors using hex values via `Color.hex(0x5B2071)`
- **Layout** — `Spacing` constants, `SafeAreaInsets`, `CircleImage`, conditional view transforms
- **View Modifiers** — Light-mode-only shadows, auto-dismiss control, dynamic type scroll wrapping

For details see [CoreUI's Documentation](./CoreUI/Sources/Documentation.docc/Documentation.md).

### CoreUIKit

UIKit utilities, view controllers, and presentation helpers.

- **View Controllers** — `BaseHostingController` for mounting SwiftUI in UIKit,
  `BaseNavigationController` with built-in styling, `PresentableController` protocol
- **Interactive Transitions** — Gesture-driven presentation and dismissal
- **Color Utilities** — `UIColor` hex, RGB, and HSB extensions
- **Font Registration** — `FontRegistrar` for programmatic custom font loading

For details see [CoreUIKit's Documentation](./CoreUIKit/Sources/Documentation.docc/Documentation.md).

### CoreStorage

Persistent storage utilities using CoreData and a lightweight disk-backed key-value store.

- **CoreData** — `PersistentDataContainer` for store loading, `DataObserver` for change
  notifications, and `ObjectStore` for type-safe CRUD operations
- **CodableStore** — `DiskBackedJSONCodableStore` provides a simple key-value API for any
  `Codable & Sendable` type, backed by JSON files on disk

For details see [CoreStorage's Documentation](./CoreStorage/Sources/Documentation.docc/Documentation.md).

### RunMode

Detects the active run mode of the current process.

```swift
let activeRunMode = RunMode.getActive()
// .mainApplication, .unitTests, or .uiUnitTests
```

For details see [RunMode's Documentation](./RunMode/Sources/Documentation.docc/Documentation.md).

## Future Improvements

### CoreUI

1. **[Toasts]** Add flexibility so developers can render any `View` as the toast content without
enforcing a `String` title.
2. **[Toasts]** Add ability to customize appearance with app-specific font, not just the default
system fonts.
3. **[Toasts]** Apply a minimum capsule size if no content is present.
4. **[Accessibility]** Add utilities for accessibility.

## Helpful Resources

See [HelpfulResources.md](./HelpfulResources.md) for educational notes on Swift concepts like
`class` vs `struct`, Automatic Reference Counting, and more.

## License

See [LICENSE](./LICENSE).
