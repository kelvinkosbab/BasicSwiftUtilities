# Versioning, Availability, and Deprecation

## Semantic versioning for libraries

Swift packages should follow [SemVer](https://semver.org/):

- **MAJOR** — breaking API changes (removing `public` symbols, changing signatures, raising minimum platform versions)
- **MINOR** — backward-compatible additions (new `public` symbols, new optional parameters)
- **PATCH** — bug fixes only, no API changes

Tag releases as `1.2.3` (no `v` prefix is the SPM convention, though `v1.2.3` works too).

## What counts as a breaking change

Breaking (requires major bump):

- Removing or renaming a `public` declaration.
- Changing a function signature (parameters, return type, throws-ness).
- Adding a non-optional case to a `public` enum (consumers' switch statements break).
- Raising the minimum platform version.
- Removing protocol conformance.

Non-breaking (minor bump is fine):

- Adding new `public` declarations.
- Adding new methods to a protocol *with a default implementation*.
- Adding a new case to a `@frozen public enum` is breaking; to a non-frozen enum it's not breaking under resilient compilation but still risky.

## `@available` annotations

Use `@available` to gate APIs to specific platform versions:

```swift
@available(iOS 17.0, macOS 14.0, *)
public func newFeature() { }
```

For deprecation:

```swift
@available(*, deprecated, renamed: "newFunction()")
public func oldFunction() { }

@available(*, deprecated, message: "Use NewType instead")
public func legacyFunction() { }
```

For removal across versions:

```swift
@available(iOS, introduced: 16.0, deprecated: 17.0, obsoleted: 18.0)
public func transitionalFeature() { }
```

## Raising the platform minimum

Raising the platform minimum (e.g., iOS 17 → iOS 18) is a **breaking change** — consumers on the old platform can no longer use your package. Bump the major version.

In `Package.swift`:

```swift
platforms: [
    .iOS("18"),  // was "17"
    .macOS("15") // was "14"
]
```

Document the change in your CHANGELOG.

## Pre-1.0 versions

Versions `0.x.y` are pre-stable. By convention, breaking changes can happen in `0.x.y` minor bumps (`0.1.0` → `0.2.0`).

Once you tag `1.0.0`, you commit to SemVer rules. Don't release `1.0.0` until your public API is stable.

## CHANGELOG conventions

Maintain a `CHANGELOG.md` following [Keep a Changelog](https://keepachangelog.com/):

```markdown
## [Unreleased]
### Added
- New `frobnicate()` method on `Widget`.

### Changed
- `Widget.color` is now optional (was non-optional).

### Deprecated
- `Widget.legacyMethod()` — use `newMethod()` instead.

### Removed
- `OldType` (deprecated in 1.5.0).

## [2.0.0] - 2026-04-24
- Initial breaking-change release.
```
