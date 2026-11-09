---
description: Memory on Apple platforms — retain cycles in closures, Tasks, Combine, timers, and delegates; image downsampling; NSCache and memory warnings; extension and watchOS budgets; jetsam; measuring with the memory graph, Instruments, MetricKit, and leak tests
globs: "**/*.swift"
paths:
  - "**/*.swift"
must:
  - "Capture `[weak self]` in escaping closures, sinks, and observers that `self` stores; a strong capture there is a leak."
  - "Never let a long-lived `Task` or `for await` loop stored on `self` capture `self` strongly; re-bind weakly per iteration."
  - "Downsample images to display size; never decode a full-size photo for a thumbnail or list cell."
  - "Use `NSCache` with a cost limit for in-memory caches, never an unbounded dictionary on a singleton."
---

# Apple Memory Management

ARC frees memory when the last strong reference goes, so a leak is a reference cycle and bloat is holding more than the screen needs. iOS has no swap: an app that grows past its limit is killed by jetsam with no crash log, and the user sees a cold launch. These are the must-follow rules. Examples and the audit workflow live in the **`swift-memory-storage-pro`** skill (`references/retain-cycles.md`, `references/memory-footprint.md`, `references/measuring.md`).

## Reference cycles

- **An escaping closure stored by `self` (directly or through something `self` owns) captures `[weak self]`.** That covers stored callbacks (`onChange: () -> Void`), Combine `sink`s kept in `cancellables`, `NotificationCenter.addObserver(forName:object:queue:using:)`, and completion handlers kept by long-lived services. Non-escaping closures and one-shot `async` calls need no capture list.
- **A long-lived `Task` stored on `self` must not hold `self` for its whole life.** A `for await` loop that captures `self` strongly keeps the object alive until the stream ends, and `deinit` (where you'd cancel it) never runs. Capture `[weak self]` and re-bind with `guard let self else { return }` *inside* each iteration, or own the work from the view with `.task { }`, which cancels on disappear.
- **`assign(to:on: self)` retains `self`**; use `assign(to: &$property)`.
- **`Timer.scheduledTimer(timeInterval:target:selector:…)` and `CADisplayLink(target:selector:)` retain their target** until invalidated. Use the block-based timer with `[weak self]`, and invalidate in a lifecycle method, not only in `deinit`.
- **Delegates and back-references to an owner are `weak var`.** Data sources passed in at init that the object doesn't own are `weak` or `unowned` only when lifetimes are guaranteed; prefer `weak`.
- `unowned` only when the referenced object provably outlives the closure; a wrong guess is a crash, not a leak.

## Footprint

- **Downsample images to the size you display.** Decoded size is width × height × 4 bytes: a 12 MP photo is ~48 MB in memory whatever its file size. Use `UIImage.preparingThumbnail(of:)` / `byPreparingThumbnail(ofSize:)` or ImageIO `CGImageSourceCreateThumbnailAtIndex` with `kCGImageSourceThumbnailMaxPixelSize`; never `UIImage(data:)` / `UIImage(contentsOfFile:)` on a full-size photo for a thumbnail.
- **In-memory caches are `NSCache` with a `totalCostLimit`**, not a `Dictionary` on a singleton. `NSCache` evicts under memory pressure; a dictionary grows until jetsam.
- **Release what you can rebuild on memory warnings** (`UIApplication.didReceiveMemoryWarningNotification`; `DispatchSource.makeMemoryPressureSource` on macOS). Don't rely on the warning arriving before a kill.
- **Lazy containers for long collections** (`List`, `LazyVStack`, `LazyVGrid`); never `VStack` + `ForEach` over hundreds of rows. Page large datasets instead of loading whole tables.
- **`@State` initial values run on every view init.** Don't allocate heavy objects in the `@State var model = Model()` expression of a view that's re-created often; create them in a parent or in `.task`.
- **Stream big data**: `Data(contentsOf:options: .mappedIfSafe)`, `FileHandle`, or `URLSession` download tasks, never a whole video or archive in a `Data`.
- `autoreleasepool { }` inside tight loops that create Objective-C objects (image processing, `NSString` bridging).

## Budgets

- **Extensions have much smaller limits than the app** (widgets, notification service, share, keyboard extensions get a few tens of MB). Load thumbnails, not originals, and never share a big in-memory cache with the app.
- **watchOS and older iPhones** fail first; test there. Check headroom before a large allocation with `os_proc_available_memory()` (iOS family).
- **`com.apple.developer.kernel.increased-memory-limit` is a last resort** for genuinely large working sets (games, ML, pro media), never a fix for a leak.

## Measure

- **Memory graph debugger** after exercising a flow: leaked objects and cycles show as purple warnings. Instruments **Leaks** and **Allocations** (generations: mark, repeat a flow, mark again; growth per generation is a leak).
- **A leak test for every view model and service with closures or Tasks**: create it in a scope, hold it `weak`, run its work, and expect `nil` after the scope.
- **Field data**: MetricKit `MXMemoryMetric.peakMemoryUsage` and `MXAppExitMetric` memory-limit exits; Xcode Organizer's Memory and Terminations reports. A rising foreground memory-limit exit count is a release blocker.
- `XCTMemoryMetric` in an XCTest performance test for screens with large media.
