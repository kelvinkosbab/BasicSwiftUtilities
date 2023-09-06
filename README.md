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

### Common communication and data transmission patterns

1. Delegation
2. Notifications
3. Key value observing

#### Delegation

The basic idea of delegation, is that a controller defines a protocol (a set of method definitions)
that describe what a delegate object must do in order to be allowed to respond to a controller’s
events. The protocol is a contract where the delegator says “If you want to be my delegate, then
you must implement these methods”.

**Pros:**
- All events to be heard are clearly defined in the delegate protocol.
- Errors are not repelled as it should be by a delegate.
- Protocol defined within the scope of the controller only.
- Very traceable, and easy to identify flow of control within an application.
- No third party object required to maintain / monitor the communication process.

**Cons:**
- Many lines of code required to define: 1. the protocol definition, 2. the delegate property in
the controller, and 3. the implementation of the delegate method definitions within the delegate itself.
- Need to be careful to correctly set delegates to `nil` on object deallocation, failure to do so
can cause memory crashes by calling methods on deallocated objects.
- Although possible, it can be difficult and the pattern does not really lend itself to have
multiple delegates of the same protocol in a controller (telling multiple objects about the same event)

#### Notifications

In iOS applications there is a concept of a “Notification Center”. The main feature of this
pattern is that the sender and recipients (there can be many) do not talk directly, like with
delegate pattern. Instead, they both talk to `NotificationCenter` - the sender calls method
`postNotification` on the `NotificationCenter` to send a notification, while recipients opt-in
for receiving the notifications by calling `addObserver` on `NotificationCenter`. They can
later opt-out with `removeObserver`. Important note though is that NotificationCenter does
not store notifications for future subscribers - only present subscribers receive the
notifications.

**Pros:**
- Easy to implement, with not many lines of code.
- Can easily have multiple objects reacting to the same notification being posted.
- Controller can pass in a context (dictionary) object with custom information (`userInfo`)
related to the notification being posted.

**Cons:**
- No compile time to checks to ensure that notifications are correctly handled by observers.
- Battery leackage or it uses more memory.
- Required to un-register with the notification center if your previously registered object
is deallocated.
- Third party object required to manage the link between controllers and observer objects.
- Notification Names, and UserInfo dictionary keys need to be known by both the observers
and the controllers. If these are not defined in a common place, they can very easily
become out of sync.

#### Observation

`KVO` is a traditional [observer pattern](https://en.wikipedia.org/wiki/Observer_pattern) built-in
any `NSObject` out of the box. With `KVO` observers can be notified of any changes of a `@property`
values. It leverages Objective-C runtime for automated notifications dispatch, and because of that
for Swift class, you would need to opt into Objective-C dynamism by inheriting `NSObject` and marking
the `var` you’re going to observe with modifier dynamic. The observers should also be `NSObject`
descendants because this is enforced by the `KVO` API.

**Pros:**
- Can provide an easy way to sync information between two objects. For example, a model and a view.
- Allows us to respond to state changes inside objects that we did not create, and don’t have
access to alter the implementations of (SKD objects).
- Can provide us with the new value and previous value of the property we are observing.
- Can use key paths to observe properties, thus nested objects can be observed.

**Cons:**
- The properties we wish to observe, must be defined using strings. Thus no compile time
warnings or checking occurs.
- Re-factoring of properties can leave our observation code no longer working.
- Complex “IF” statements required if an object is observing multiple values.
- Need to remove the observer when it is deallocated.

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
learn app development with UIKit and SwiftUI.

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

### Swift concurrency resources

- [Async await in Swift explained with code examples](https://www.avanderlee.com/swift/async-await/)
- [Actors in Swift: how to use and prevent data races](https://www.avanderlee.com/swift/actors/)
- [Swift actors: How do they work, and what kinds of problems do they solve?](https://www.swiftbysundell.com/articles/swift-actors/)
- [Sendable and @Sendable closures explained with code examples](https://www.avanderlee.com/swift/sendable-protocol-closures/)

### Other resources

- [MVVM Architectural Design Pattern in Swift](https://medium.com/dev-genius/mvvm-architectural-design-pattern-in-swift-87dde74758b0)
- [VIPER Design Pattern in Swift](https://blog.devgenius.io/viper-design-pattern-with-a-basic-example-2a5802f6e6f1)
- [Haacking with Swift interview questions](https://www.hackingwithswift.com/interview-questions)

## License

See [LICENSE](./LICENSE).
