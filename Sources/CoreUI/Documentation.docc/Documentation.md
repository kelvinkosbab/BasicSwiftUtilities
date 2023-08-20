# ``CoreUI``

Provides `UIKit` and `SwiftUI` helpers, components, and utilities.

- Font utilies and custom font registration

- SwiftUI components:
  - Activity indicator
  - Blurred view modifier
  - Button styles and view modifiers
  - Color utiliites
  - Core spacing and margins
  - Application toast provider

## `UIKit` utilities

### ``PresentableController``

In an application ``PresentableController`` ([link](../UIKit/PresentableController/PresentableController.swift)) is a protocol to help view controllers present,
manage, and dismiss view controllers. The utilities provided by this protocol's extensions
provide ways to simplify every step in the process.

### `Storyboard` utilities.

Provides helpers for creating `UIViewController` objects that are
defined with via a `Storyboard`. See ``StoryboardViewController`` ([link](../UIKit/StoryboardViewController.swift)) for
more information.  

### Base view controllers

``BaseNavigationController`` ([link](../UIKit/BaseViewControllers/BaseNavigationController.swift)) is a controller which provides styling utilities for
navigation controllers including customizing large titles, tint color and translucent style.

``BaseHostingController`` ([link](../UIKit/BaseViewControllers/BaseHostingController.swift)) is a controller to simplify mounting a `SwiftUI` view in a
`UIKit` view controller.

### Ability to define colors by hex values

Here is an example of how to define a `UIColor` object via its hex value:
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

### Toast utilities

The ``ToastableContainer`` ([link](../Toasts/ToastableContainer.swift)) component helps for displaying simple toasts in an app's window.
Toasts can be configured to be displayed from the top or the bottom of the app's window and
can contain a title, description (optional), leading image (optional), trailing image (optional).

```swift
@main
struct CoreSampleApp: App {

    let toastApi = ToastApi()

    var body: some Scene {
        WindowGroup {
            ContentView(toastApi: self.toastApi)
                .toastableContainer(toastApi: self.toastApi)
        }
    }
}

// In a sub-component:
Button("Bottom: Show Simple Title") {
    self.toastApi.show(title: "Simple Title")
}
```

### Safe area utilities

The `@Environment(\.safeAreaInsets) private var safeAreaInsets` utilitiy provides access to
the app window's safe are inset values for a component. ([link](../SafeAreaInsets.swift))

### Ability to define colors by hex values

Here is an example of how to define a `Color` object via it's hex value:
```swift
ZStack {
    Color.halo(.core900)
    Image(systemName: "sun.max.fill")
        .foregroundStyle(.hex(0x5B2071)) // For hex "#5B2071"
}
.frame(width: 200, height: 100)
```

See [HexColor](../Colors/HexColor.swift) for implementation details.
