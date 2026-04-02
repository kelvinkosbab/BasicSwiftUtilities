# ``CoreUIKit``

UIKit utilities, view controllers, and presentation helpers.

## Overview

CoreUIKit provides UIKit-specific components that complement the SwiftUI utilities in ``CoreUI``.
Import both modules when you need UIKit and SwiftUI interoperability.

## View Controllers

### ``PresentableController``

A protocol to help view controllers present, manage, and dismiss other view controllers with
simplified APIs for every step in the process.

### ``BaseNavigationController``

A navigation controller with built-in styling utilities for large titles, tint colors, and
translucent navigation bars.

### ``BaseHostingController``

A controller that simplifies mounting a SwiftUI view inside a UIKit view controller hierarchy.

### ``StoryboardViewController``

A protocol for instantiating view controllers defined in storyboard files.

## Interactive Transitions

- ``InteractivePresentationController`` — Custom presentation controller with interactive
  dismiss support.
- ``InteractiveTransition`` — Gesture-driven transitions using pan gestures.

## Color Utilities

- `UIColor.hex(_:opacity:)` — Create a `UIColor` from a hex integer value.
- `UIColor` HSB and RGB value extraction utilities.

## Other Utilities

- `UIView.addToContainer(view:)` — Add a view to a container with auto-layout constraints.
- `UIViewController.add(childViewController:intoContainerView:)` — Mount a child view controller.
- `UIViewController.remove(childViewController:)` — Remove a child view controller.
- `UINavigationController.push(viewController:completion:)` — Push with completion handler.
- `FontRegistrar` — Programmatic custom font registration.
