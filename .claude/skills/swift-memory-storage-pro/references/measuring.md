# Measuring memory and storage

Confirm a suspected problem before reporting it as certain, and confirm a fix before calling it done.

## Memory graph debugger

1. Run a Debug build, exercise the flow (open the screen, use it, leave it) two or three times.
2. Click **Debug Memory Graph** in the debug bar.
3. Leaked objects show a purple warning in the issue navigator. Filter the object list by type name: if three `FeedViewModel` instances exist after visiting the feed three times and leaving, it leaks.
4. Select an instance to see who retains it; the cycle is usually visible in the graph.
5. Enable **Malloc Stack Logging** (scheme → Diagnostics → Live Allocations Only) to see where each object was allocated.

`leaks` from the command line works on a memory graph exported from Xcode (`File → Export Memory Graph`): `leaks MyApp.memgraph`.

## Instruments

- **Leaks**: finds unreachable cycles automatically. Misses leaks that are still reachable (a singleton dictionary that grows), so pair it with Allocations.
- **Allocations, with generations**: start recording, mark a generation, perform a flow and return to the start, mark again; repeat. Persistent growth in each generation after the first is retained memory that should have gone.
- **VM Tracker** and the **Memory** gauge: dirty and compressed memory, which is what counts toward the jetsam limit. Image decodes show up as large `CG image` / `IOSurface` regions.
- Profile a Release build on a real, older device; the simulator uses the Mac's memory and has no jetsam.

## Leak tests

Swift Testing:

```swift
@Test func feedViewModelIsReleasedAfterLoading() async {
    weak var weakModel: FeedViewModel?
    do {
        let model = FeedViewModel(repository: FakeFeedRepository())
        weakModel = model
        await model.load()
        model.startObservingUpdates()
        model.stopObservingUpdates()
    }
    #expect(weakModel == nil)
}
```

XCTest, as a reusable helper:

```swift
extension XCTestCase {
    func assertReleased(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Leaked: retained after the test", file: file, line: line)
        }
    }
}
```

- Add one for each type that stores closures, Tasks, subscriptions, or observers, and for each cycle you fix.
- If the object owns an unfinished Task, the test fails until the Task is cancelled or finishes: that's usually the bug.

## Performance tests

```swift
func testGalleryScrollMemory() {
    let app = XCUIApplication()
    measure(metrics: [XCTMemoryMetric(application: app)]) {
        app.launch()
        app.collectionViews.firstMatch.swipeUp(velocity: .fast)
        app.terminate()
    }
}
```

Set a baseline in Xcode and fail on regressions. XCTest owns performance tests (`apple-testing-strategy.md`).

## Field data

- **MetricKit**: subscribe with `MXMetricManager.shared.add(_:)`.
  - `MXMemoryMetric.peakMemoryUsage` and `averageSuspendedMemory`.
  - `MXAppExitMetric.foregroundExitData.cumulativeMemoryResourceLimitExitCount` (jetsam while in use) and `backgroundExitData.cumulativeMemoryPressureExitCount` (killed in the background to free memory, normal in moderation).
- **Xcode Organizer**: Memory, Terminations (memory limit), and Disk Writes reports per release. Disk Writes flags apps that write excessively, which wears storage and drains battery.
- A jump in foreground memory-limit exits after a release is a regression; compare by device model.

## Storage inspection

- Simulator: `xcrun simctl get_app_container booted com.example.MyApp data` prints the data container path; inspect with `du -sh` per directory.
- Device: Xcode → Devices and Simulators → select the app → Download Container; the `.xcappdata` package shows `Documents`, `Library/Application Support`, `Library/Caches`, and `tmp`.
- Check what's backed up: everything under Documents and Library except Caches and items excluded from backup. On device, Settings → [name] → iCloud → Manage Storage → Backups shows per-app backup size.
- Settings → General → iPhone Storage shows "App Size" vs "Documents & Data"; a Documents & Data figure that only grows means no cleanup.
- Exercise low-space behavior by filling the simulator's disk image or testing on a nearly full device; the app should report errors, not crash, and caches should be rebuildable.
