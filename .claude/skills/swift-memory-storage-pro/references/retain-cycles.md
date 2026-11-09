# Retain cycles

ARC frees an object when its strong reference count reaches zero. A cycle (A holds B, B holds A) never reaches zero, so neither object's `deinit` runs. To report a cycle, name every link in the path back to `self`.

## Closures

A closure captures the variables it uses strongly. It only causes a cycle when the closure is **stored** somewhere `self` (transitively) owns.

```swift
// Cycle: self → onSelect → closure → self
final class ListController {
    var onSelect: ((Item) -> Void)?
    func bind() {
        onSelect = { item in self.open(item) }
    }
}

// Fixed
onSelect = { [weak self] item in self?.open(item) }
```

No cycle, no capture list needed:

- Non-escaping closures (`map`, `filter`, `withAnimation`, `forEach`).
- `async` calls awaited in place: `let user = await api.user()`.
- Escaping closures handed to an object `self` doesn't own and that drops them when done (`URLSession.dataTask` completion, `DispatchQueue.async`). These delay deallocation until the work finishes but don't leak.

`[weak self]` then `guard let self else { return }` at the top of the closure is the standard shape. In a long closure that awaits, re-check after each suspension point if it matters whether `self` is still alive.

## Tasks

`Task { }` inherits the actor and captures `self` implicitly, without writing `self.`. The task holds `self` until it finishes.

- **Short, finite tasks are fine.** A `Task { await load() }` that ends in a second only delays `deinit`.
- **Infinite or long tasks stored on `self` are cycles**: `self` → `task` → closure → `self`. `deinit` would cancel it, but `deinit` never runs.

```swift
// Leak: the loop keeps self alive as long as the stream is open
monitorTask = Task {
    for await status in monitor.statuses { self.status = status }
}

// Fixed: weak capture, re-bind inside the loop. A guard before the loop
// would hold self strongly for the loop's whole life.
monitorTask = Task { [weak self, monitor] in
    for await status in monitor.statuses {
        guard let self else { return }
        self.status = status
    }
}
```

Better still, let SwiftUI own it: `.task { await model.observe() }` cancels when the view disappears, and the task's reference to `model` ends with it.

Detached tasks and `TaskGroup` children follow the same rule: what they capture lives until they finish.

## Combine

- `sink { self.x = $0 }.store(in: &cancellables)` is a cycle: `self` → `cancellables` → `AnyCancellable` → closure → `self`. Use `[weak self]`.
- `assign(to: \.x, on: self)` retains `self` strongly: same cycle. Use `assign(to: &$x)`, which ties the subscription to the `@Published` property and doesn't retain `self`.
- An `AnyCancellable` that's never stored cancels immediately; that's a bug, not a leak.

## NotificationCenter, KVO, and observers

- `addObserver(forName:object:queue:using:)` returns a token that the center retains along with the closure. Capture `[weak self]` and remove the token when done. Prefer the async sequence: `for await _ in NotificationCenter.default.notifications(named: …)` inside a `.task` or a weak-capturing Task.
- `observe(\.keyPath, options:changeHandler:)` returns an `NSKeyValueObservation`; storing it on `self` with a strong capture is a cycle.
- With Observation, `withObservationTracking` re-registers per change; capture weakly in the `onChange` closure if you re-arm from it.

## Timers and display links

`Timer.scheduledTimer(timeInterval:target:selector:userInfo:repeats:)` and `CADisplayLink(target:selector:)` retain their target, and the run loop retains the timer. A repeating timer whose target is `self` keeps `self` alive forever, and invalidating it in `deinit` never runs.

```swift
// Fixed: block-based timer with a weak capture, invalidated by lifecycle
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
    self?.tick()
}
// in onDisappear / viewWillDisappear / stop(): timer?.invalidate()
```

For display links, use a small proxy object as the target that holds `self` weakly and forwards the callback, and invalidate the link when the view goes away. In SwiftUI, `TimelineView` avoids the problem.

## Delegates and back-references

- Delegates are `weak var delegate: SomeDelegate?` with the protocol constrained to `AnyObject`.
- A child that refers back to its parent or coordinator holds it `weak`.
- `unowned` is for references where the other object is guaranteed to outlive this one (a child owned exclusively by its parent). If that guarantee breaks, `unowned` crashes; `weak` would have returned nil. Default to `weak`.

## SwiftUI ownership

- Views are values; they don't leak. The objects they hold do.
- `@State var model = Model()` creates a new `Model` on every init of the view struct; SwiftUI keeps the first and discards the rest. That's allocation churn, and side effects in `Model.init` run repeatedly. Do work in `.task`, not `init`.
- An environment object or singleton that stores closures from views (`register(handler:)`) keeps each view's model alive. Return a token and remove it in `onDisappear`, or use `.task` with an async sequence.
- `UIViewRepresentable` coordinators referencing the parent representable copy a value, not a cycle; a coordinator referencing a view model it was given is fine as long as the model doesn't store the coordinator strongly.

## Objective-C and mixed code

- Blocks capture `self` strongly; use the `__weak typeof(self) weakSelf = self;` / `__strong` dance (`apple-objc-best-practices.md`).
- `NSTimer` and `CADisplayLink` targets behave the same as in Swift.
- `performSelector:withObject:afterDelay:` retains the target until it fires.
