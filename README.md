# BasicSwiftUtilities

This package provides basic utilities and APIs for an application running on Apple's platforms'.

Note: This pacakge is designed such that its only dependency is Apple's frameworks. 

Developed by Kelvin Kosbab
kelvin.kosbab@kozinga.net
https://kelvinkosbab.github.io/BasicSwiftUtilities

## Core

Provides basic utilities for an app running on Apple platforms.

See [`Core`](./Sources/Core/Documentation/Documentation.md).

## CoreHealth

Provides utilties for accessing Apple's `HealthKit` APIs. These APIs wrap Apple's APIs to provide
useful ways to query data safely via units that each health biometric supports (`HealthKit`'s APIs
will crash the app if the trying to convert a biometric value to the wront unit which is not
an elegant way of handling this behavior).

## CoreStorage

Provides utilities for persistently storing data. This pacakge includes utilities for Apple's
`CoreData` as well as a custom `SQLite` implementation, ``CodableStore`` and
``DiskBackedJSONCodableStore``.

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


