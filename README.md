# BasicSwiftUtilities

This repository provides basic utilities and APIs for an application running on Apple's platforms'.

Developed by Kelvin Kosbab
kelvin.kosbab@kozinga.net
https://kelvinkosbab.github.io/BasicSwiftUtilities

## Swift packages and frameworks included in this package

This repository contains the following Swift packages (also supports exporting of dynamic frameworks via `BasicSwiftUtilitesFramework.xcproject`):
- ``Core``
- ``CoreHealth``
- ``CoreStorage``
- ``CoreUI``
- ``RunMode``

For detailed information of these packages / frameworks see below.

Note: This pacakge is designed such that its only dependency is Apple's various fundamental frameworks.

**Platform Support:**
- iOS 10.0
- macOS 11.0
- tvOS 10.0
- watchOS 3.0
- visionOS 1.0

### Core

Provides basic utilities for an app running on Apple platforms.

For a full breakdown and details see [`Core's Documentation`](./Sources/Core/Documentation.docc/Documentation.md).

### CoreHealth

Provides utilties for accessing Apple's `HealthKit` APIs. These APIs wrap Apple's APIs to provide
useful ways to query data safely via units that each health biometric supports.

For a full breakdown and details see [`CoreHealth's Documentation`](./Sources/CoreHealth/Documentation.docc/Documentation.md).

### CoreStorage

Provides utilities for persistently storing data. This pacakge includes utilities for Apple's
`CoreData` as well as a custom `SQLite` implementation, ``CodableStore`` and
``DiskBackedJSONCodableStore``.

For a full breakdown and details see [`CoreStorage's Documentation`](./Sources/CoreStorage/Documentation.docc/Documentation.md).

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

For a full breakdown and details see [`CoreUI's Documentation`](./Sources/CoreUI/Documentation.docc/Documentation.md).

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

For a full breakdown and details see [`RunMode's Documentation`](./Sources/RunMode/Documentation.docc/Documentation.md).

## Useful topics to learn about for developing on Apple's platforms

### What are the differences between `struct` vs `class`?

Structures and classes are good choices for storing data and modeling behavior in your apps, but their similarities can make it difficult to choose one over the other.

Consider the following recommendations to help choose which option makes sense when adding a new data type to your app.

- Use structures by default.
- Use classes when you need Objective-C interoperability.
- Use classes when you need to control the identity of the data you’re modeling.
- Use structures along with protocols to adopt behavior by sharing implementations.

> More resources:
> - Apple Developer's [Choosing Between Structures and Classes documentation](https://developer.apple.com/documentation/swift/choosing-between-structures-and-classes).
> - Antoine Van Der Lee's post [Struct vs classes in Swift: The differences explained](https://www.avanderlee.com/swift/struct-class-differences/). 

## Useful Learning Resources

Getting into a new software stack can be overwhelming. Here are some resources I have found
useful for understanding core concepts of developing on Apple Platforms and develpoing with
the Swift programming language.

### Kodeco / Ray Wenderlich

RayWenderlich (rebranded to Kodeco) have been providing useful programming resources for 
more than a decade. This site is one of the best investments for mobile developers.

See [Kodeco's iOS and Swift Start Page](https://www.kodeco.com/ios/paths/learn).

### Hacking with Swift

With more free Swift tutorials than any other site, Hacking with Swift will help you
\learn app development with UIKit and SwiftUI.

See [hackingwithswift.com](https://www.hackingwithswift.com).

### The Wisdom of Quinn

The [Wisdom of Quinn GitHub page](https://github.com/macshome/The-Wisdom-of-Quinn) provides resources for just
about everyting for developering on Apple's platforms including but by no means limited to:
- [Code Signing](https://github.com/macshome/The-Wisdom-of-Quinn#code-signing)
- [Distribution](https://github.com/macshome/The-Wisdom-of-Quinn#distribution)
- [File Systems](https://github.com/macshome/The-Wisdom-of-Quinn#filesystems)
- [Security](https://github.com/macshome/The-Wisdom-of-Quinn#security)
- [Logging](https://github.com/macshome/The-Wisdom-of-Quinn#logging)
- and much... much more...

## License

See [LICENSE](./LICENSE).
