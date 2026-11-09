---
name: swift-memory-storage-pro
description: Audits Apple-platform apps for memory and on-device storage problems — retain cycles in closures, Tasks, Combine, timers, and delegates; image decode size; unbounded caches; extension and watchOS budgets; jetsam exits; the wrong directory for a file, iCloud backup bloat, secrets in UserDefaults, missing file protection, unbounded disk caches, free-space handling, app size, and disk-space / file-timestamp privacy manifest reasons. Use when investigating memory growth, leaks, jetsam terminations, storage complaints, backup rejections, or when reviewing code that caches, decodes images, or writes files.
license: MIT
metadata:
  author: AppBootstrapAI contributors
  version: "1.0"
  grounded_in: "Apple documentation on ARC and reference cycles, ImageIO thumbnails, NSCache, MetricKit (MXMemoryMetric, MXAppExitMetric), Xcode memory graph and Instruments Leaks/Allocations, File System Programming Guide directory roles, isExcludedFromBackup, Data Protection, Keychain accessibility, volume capacity keys, Background Assets, and the privacy manifest required-reason API categories"
---

Audit Swift code for memory and storage problems. This is the deep-review companion to the always-on `apple-memory-management.md` and `apple-storage-management.md` rules: the rules steer while writing; this skill traces ownership, footprint, and file placement across whole features. Report only genuine problems.

If asked to **fix** rather than review, make the changes directly and summarize them in the same file-by-file format.

Review process:

1. **Leaks.** For each type that stores closures, Tasks, Combine subscriptions, timers, observers, or delegates, trace who owns whom using `references/retain-cycles.md`. A cycle needs a path back to `self`; confirm it before reporting.
2. **Footprint.** Check image decoding, in-memory caches, collection loading, and extension budgets using `references/memory-footprint.md`.
3. **Storage.** For every file write, UserDefaults key, Keychain item, and disk cache, check the location, backup status, protection class, size cap, and privacy manifest reason using `references/storage-layout.md`.
4. **Evidence.** When the user reports a symptom (memory growth, jetsam exits, disk use), or before you claim a fix worked, use `references/measuring.md` to reproduce and confirm it with the memory graph, Instruments, MetricKit, or a leak test. Add a leak test for each cycle you fix.

For a partial review (only leaks, only storage), load only the matching reference.

## Core Instructions

- **A cycle is only a finding when you can name the path.** `self` → `cancellables` → sink closure → `self` is a cycle; a `[weak self]` missing from a non-escaping or one-shot closure is not. Don't spray `[weak self]` everywhere as a "fix".
- **Size findings in bytes.** "Decodes a 4032×3024 photo for a 60pt thumbnail: ~48 MB per cell" is actionable; "large image" is not.
- **Location findings name the consequence**: backed up when it shouldn't be (iCloud bloat, App Review), purgeable when it shouldn't be (offline content disappears), readable while locked when it holds sensitive data.
- **Severity by user impact**: crash or data loss (jetsam on a common flow, secrets in plain files, offline content in Caches, missing privacy manifest reason) > degraded (leaked view models, unbounded cache growth, backup bloat) > hygiene (missing size cap on a small cache, no storage settings screen).
- Cross-reference, don't duplicate: actor isolation belongs to `swift-concurrency-pro`; Core Data and SwiftData store setup to `coredata-swift6-pro` / `swiftdata-pro`; logging what you measured to `swift-logging-pro`.

## Output Format

Organize findings by file. For each issue: file/line, the problem, the measured or estimated cost (bytes, objects, or files), and a brief before/after. Skip clean files. End with a prioritized summary.

Example finding:

### FeedViewModel.swift

**Line 31: the update loop holds `self` forever, so every visit to the feed leaks a view model.**

```swift
// Before
updatesTask = Task {
    for await update in repository.updates() {
        apply(update)
    }
}

// After: capture weakly, re-bind per iteration
updatesTask = Task { [weak self, repository] in
    for await update in repository.updates() {
        guard let self else { return }
        self.apply(update)
    }
}
```

### Summary

1. **Crash risk:** `PhotoGridCell` decodes originals (~48 MB each) for 80pt thumbnails; jetsam after ~10 cells on a 3 GB device.
2. **Degraded:** `FeedViewModel` leaks on every visit (Task holds `self`).
3. **Hygiene:** `URLCache.shared` left at the default size while the app prefetches video posters.

End of example.

## References

- `references/retain-cycles.md` — closures, Tasks and `for await`, Combine, NotificationCenter, timers and display links, delegates, `weak` vs `unowned`, SwiftUI ownership.
- `references/memory-footprint.md` — image downsampling, NSCache, memory warnings and pressure, lazy containers, streaming, autorelease pools, extension and watchOS budgets, the increased-memory-limit entitlement.
- `references/storage-layout.md` — the directory decision table, backup exclusion, UserDefaults limits, Keychain, file protection, app groups, atomic writes, free space, cache budgets, app size, privacy manifest reasons.
- `references/measuring.md` — memory graph debugger, Instruments generations, leak tests in Swift Testing and XCTest, `XCTMemoryMetric`, MetricKit and Organizer, storage inspection with `simctl` and container downloads.
