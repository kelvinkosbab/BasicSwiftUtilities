# BasicSwiftUtilities

This repository provides basic utilities and APIs for an application running on Apple's platforms'.

This repository also includes some useful resources for developing on Apple's platforms such as
`class` vs `struct`, Automatic Reference Counting, and more. (see [HelpfulResources.md](./HelpfulResources.md)))

Developed by Kelvin Kosbab
kelvin.kosbab@kozinga.net
https://kelvinkosbab.github.io/BasicSwiftUtilities

## Swift packages and frameworks included in this package

This repository contains the following Swift packages (also supports exporting of dynamic
frameworks via `BasicSwiftUtilitesFramework.xcproject`):
- ``Core``
- ``CoreHealth``
- ``CoreStorage``
- ``CoreUI``
- ``RunMode``

For detailed information of these packages / frameworks see below.

Note: This pacakge is designed such that its only dependency is Apple's various fundamental frameworks.

**Platform Support:**
- iOS 15.0
- macOS 12.0
- tvOS 15.0
- watchOS 7.0
- visionOS 1.0

### Core

Provides basic utilities for an app running on Apple platforms.

For a full breakdown and details see [`Core`'s Documentation](./Sources/Core/Documentation.docc/Documentation.md).

### CoreHealth

Provides utilties for accessing Apple's `HealthKit` APIs. These APIs wrap Apple's APIs to provide
useful ways to query data safely via units that each health biometric supports.

For a full breakdown and details see [`CoreHealth`'s Documentation](./Sources/CoreHealth/Documentation.docc/Documentation.md).

### CoreStorage

Provides utilities for persistently storing data. This pacakge includes utilities for Apple's
`CoreData` as well as a custom `SQLite` implementation, ``CodableStore`` and
``DiskBackedJSONCodableStore``.

For a full breakdown and details see [`CoreStorage`'s Documentation](./Sources/CoreStorage/Documentation.docc/Documentation.md).

### CoreUI

Provides `UIKit` and `SwiftUI` helpers, components, and utilities.

- Font utilies and custom font registration
- SwiftUI components:
  - Activity indicator
  - Blurred view modifier
  - Button styles and view modifiers
  - Color utiliites
  - Core spacing and margins
  - Application toast provider
- UIKit utilities:
  - View controller presentation and navigation utilities
  - Interactive view controller presentation utilities
  - `UIView` and `UIViewController` utilities

For a full breakdown and details see [`CoreUI`'s Documentation](./Sources/CoreUI/Documentation.docc/Documentation.md).

### RunMode

Determines the active run mode off the current process.

Possibilities include:
 - Main application
 - Unit tests
 - UI unit tests

To determine the current process's ``RunMode``:
```swift
let activeRunMode = RunMode.getActive()
```

For a full breakdown and details see [`RunMode`'s Documentation](./Sources/RunMode/Documentation.docc/Documentation.md).

## Features to be added to this package in the future:

### CoreHealth

1. Support for `HKAnchoredObjectQuery` queries with type-safe and unit-safe implementation.

### CoreUI

1. **[Toasts]** Add flexibility so developers can render any `View` as the toast content without
enforcing a `String` title.

2. **[Toasts]** Add ability to customize appearance with app-specific font, not just the default
system fonts. 

3. **[Toasts]** Apply a minimum capsule size if no content is present.

4. **[Accessibility]** Add utilities for accessibility.

## License

See [LICENSE](./LICENSE).
