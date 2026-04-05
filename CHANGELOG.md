# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- **CoreUIKit** module — UIKit utilities split out from CoreUI for cleaner SwiftUI/UIKit separation
- **CoreUIKit** test coverage for `UIColor` utilities and `PresentationMode`
- Test coverage for retry logic (`RetryStrategy`, sync and async retry)
- Test coverage for `DiskBackedJSONCodableStore` (set/get, remove, type erasure)
- Documentation comments on all public-facing declarations
- `CONTRIBUTING.md` with development guidelines
- `makeTargets` helper in `Package.swift` to reduce target definition boilerplate

### Changed
- **Swift 6.0** with strict concurrency (`swiftLanguageMode(.v6)`) across all targets
- **Platform minimums** raised to iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1
- **Package layout** reorganized to colocate sources and tests per module (`{Module}/Sources/`, `{Module}/Tests/`)
- `DiskBackedJSONCodableStore` converted from class with `DispatchQueue` to `actor`
- `LongRunningTaskOrchestrator` converted from struct with `DispatchQueue` to `actor`
- `CodableStore` protocol changed from `AnyObject` to `Sendable`
- `ToastStateManager` now uses `Task.sleep` instead of `DispatchQueue.main.asyncAfter`
- All tests migrated from XCTest to Swift Testing framework
- GitHub Actions workflow updated to `actions/checkout@v4`
- `eraseMyType()` renamed to `eraseToAnyCodableStore()` for clarity

### Removed
- **CoreHealth** module (moved to a separate package)
- `Concurrency.swift` — Void continuation helpers (unnecessary with modern Swift)
- `LoggableOSLog.swift` — Legacy `os_log` wrapper (replaced by `os.Logger` with iOS 17+ minimum)
