# BasicSwiftUtilities

This package provides basic utilities and APIs for an application running on Apple's platforms'.

Note: This pacakge is designed such that its only dependency is Apple's frameworks. 

Developed by Kelvin Kosbab
kelvin.kosbab@kozinga.net
https://kelvinkosbab.github.io/BasicSwiftUtilities

## Core

Provides basic utilities for an app running on Apple platforms.

See [`Core's Documentation`](./Sources/Core/Documentation.docc/Documentation.md).

## CoreHealth

Provides utilties for accessing Apple's `HealthKit` APIs. These APIs wrap Apple's APIs to provide
useful ways to query data safely via units that each health biometric supports.

See [`CoreHealth's Documentation`](./Sources/CoreHealth/Documentation.docc/Documentation.md).

## CoreStorage

Provides utilities for persistently storing data. This pacakge includes utilities for Apple's
`CoreData` as well as a custom `SQLite` implementation, ``CodableStore`` and
``DiskBackedJSONCodableStore``.

See [`CoreStorage's Documentation`](./Sources/CoreHealth/Documentation.docc/Documentation.md).

## CoreUI

Provides `UIKit` and `SwiftUI` helpers, components, and utilities.

- Font utilies and custom font registration

- SwiftUI components:
  - Activity indicator
  - Blurred view modifier
  - Button styles and view modifiers
  - Color utiliites
  - Core spacing and margins
  - Application toast provider

See [`CoreUI's Documentation`](./Sources/CoreHealth/Documentation.docc/Documentation.md).
