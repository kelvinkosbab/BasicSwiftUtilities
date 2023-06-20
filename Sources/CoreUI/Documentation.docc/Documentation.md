# ``CoreUI``

Provides `UIKit` and `SwiftUI` helpers, components, and utilities.

- Font utilies and custom font registration

- SwiftUI components:
  - Activity indicator
  - Blurred view modifier
  - Button styles and view modifiers
  - Color utiliites
  - Core spacing and margins
  - Toasts

## `UIKit` Uutilities

### ``PresentableController``

abc

### ``InteractiveTransition``

abc

### `Storyboard` utilities.

Provides helpers for creating `UIViewController` objects that are
defined with via a `Storyboard`. See ``StoryboardViewController`` for
more information.  

### Base view controllers

``BaseNavigationController`` is a controller which provides styling utilities for
navigation controllers including customizing large titles, tint color and translucent style.

``BaseHostingController`` is a controller to simplify mounting a `SwiftUI` view in a
`UIKit` view controller.

### Ability to define colors by hex values

Here is an example of how to define a `UIColor` object via it's
hex value:
```swift
let view = UIView()
view.backgroundColor = .hex(0x5B2071) // For hex "#5B2071"
```

### Other utilities

 - `UIView.addToContainer(view:)` to simplify adding a view to a container. 
 - `UIViewController.add(childViewController:intoContainerView:)` to simplify mounting a child
view controller and its view into a view controller.
 - `UIViewController.remove(childViewController:)` to simplify removing a child view controller
and its view from a view controller.
 - `UIViewController.topPresentedController` to look for the app's top presented controller.
 - `UINavigationViewController.push(viewController:)` to push a view controller with a completion
handler for when the animation has completed.
- `UINavigationViewController.popToRootViewController()` to push a view controller with a
completion handler for when the animation has completed.
- `UINavigationViewController.pop(viewController:)` to pop to the provided view controller with
a completion handler for when the animation has completed.

## `SwiftUI` utilities

### Ability to define colors by hex values

Here is an example of how to define a `Color` object via it's
hex value:
```swift
ZStack {
    Color.halo(.core900)
    Image(systemName: "sun.max.fill")
        .foregroundStyle(.hex(0x5B2071)) // For hex "#5B2071"
}
.frame(width: 200, height: 100)
```
