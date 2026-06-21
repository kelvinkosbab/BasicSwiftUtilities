# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- **LocalNetworkMonitor** module — Wi-Fi / wired Ethernet reachability
  monitor backed by `Network.framework`'s `NWPathMonitor`. Wraps the
  framework callback in an `AsyncStream` so consumers stay in pure
  Swift Concurrency. Ships with a `LocalNetworkMonitorProtocol`,
  the `LocalNetworkMonitor` production type, and a
  `MockLocalNetworkMonitor` for tests and previews.
- **SwiftLint** via `SwiftLintPlugins` as a build-tool plugin on every
  source target. Conservative starter config in `.swiftlint.yml` with
  high-value opt-in rules (`empty_count`, `first_where`, `explicit_init`,
  `sorted_imports`, `redundant_type_annotation`, etc.). Per the
  apple-linting-strategy rule.

### Changed
- `Spacing` is now a caseless `enum` (was an empty `struct`) to prevent
  accidental instantiation.
- `MILLISECONDS_IN_SECOND` constant renamed to `millisecondsInSecond` to
  match Swift naming conventions (was SCREAMING_SNAKE_CASE).
- **Core** module now ships a `PrivacyInfo.xcprivacy` declaring the
  module's use of `ProcessInfo.systemUptime` (via
  `LongRunningTaskOrchestrator`). Consuming apps no longer need to add
  `NSPrivacyAccessedAPICategorySystemBootTime` with reason `35F9.1` to
  their own manifest — Xcode's privacy report aggregates Core's
  declaration automatically. Prevents `ITMS-91053` upload rejections.

## [1.0.1] - 2026-05-09

### Fixed
- `ToastBackgroundModifier`: build failure on Xcode <26 (which lacks the
  iOS 26 SDK). The Liquid Glass branch is now gated by `#if compiler(>=6.2)`
  so the package compiles on older toolchains and gracefully falls back to
  the translucent-material background.

## [1.0.0] - 2026-04-24

### Added
- **CoreUIKit** module — UIKit utilities split out from CoreUI for cleaner SwiftUI/UIKit separation
- **CoreUIKit** test coverage for `UIColor` utilities and `PresentationMode`
- Test coverage for retry logic (`RetryStrategy`, sync and async retry)
- Test coverage for `DiskBackedJSONCodableStore` (set/get, remove, type erasure)
- Documentation comments on all public-facing declarations, with `## Topics` sections on key types
- `CONTRIBUTING.md` with development guidelines
- `makeTargets` helper in `Package.swift` to reduce target definition boilerplate
- `InternalImportsByDefault` Swift 6 upcoming feature flag
- Bundled Claude Code skills and rules under `.claude/`
- `CircleImage(decorative:)` initializer parameter for VoiceOver hiding
- Toast accessibility — combined-children element + decorative-element hiding

### Changed
- **Swift 6.0** with strict concurrency (`swiftLanguageMode(.v6)`) across all targets
- **Platform minimums** raised to iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1
- **Package layout** reorganized to colocate sources and tests per module (`{Module}/Sources/`, `{Module}/Tests/`)
- `DiskBackedJSONCodableStore` converted from class with `DispatchQueue` to `actor`
- `LongRunningTaskOrchestrator` converted to actor; replaced remaining `DispatchWorkItem` / `DispatchQueue.main.asyncAfter` with structured `Task` + `Task.sleep(for:)`
- `CodableStore` protocol changed from `AnyObject` to `Sendable`
- `ToastStateManager` now uses `Task.sleep(for:)` instead of `DispatchQueue.main.asyncAfter`, and propagates cancellation correctly
- `ToastApi` migrated from `ObservableObject` / `@Published` to `@Observable`
- `HexColor` and `RGBColor` promoted to `public` (and `Sendable`) so consumers can use them across modules
- `DiskBackedJSONCodableStoreError` cause is now a `String` description (eliminates `@unchecked Sendable`)
- `PersistentDataContainerError.failedToLocateModel` now takes `bundleIdentifier: String?` instead of `Bundle` (sendability)
- `DataObserver.init` is now throwing — propagates initial-fetch failures
- `ObjectStore.newObserver(...)` variants are now throwing
- `FontRegistrar.Error` renamed to `FontRegistrationError` and conforms to `LocalizedError, Sendable`
- All tests migrated from XCTest to Swift Testing framework
- GitHub Actions workflow updated to `actions/checkout@v4`
- `eraseMyType()` renamed to `eraseToAnyCodableStore()` for clarity

### Removed
- **CoreHealth** module (moved to a separate package)
- `Concurrency.swift` — Void continuation helpers (unnecessary with modern Swift)
- `LoggableOSLog.swift` — Legacy `os_log` wrapper (replaced by `os.Logger` with iOS 17+ minimum)
- Custom `CoreStorage.Result` type (use `Swift.Result<Void, Error>` instead)

### Fixed
- `DiskBackedJSONCodableStoreError` description strings had unbalanced parentheses
- `PersistentDataContainer.configure(fileProtectionType:)` previously appended a duplicate description (which was ignored after store load) — now mutates existing descriptions, must be called before `load()`
- Cancellation in `asyncRetry` and `ToastStateManager` no longer silently swallowed by `try?`
