---
name: swift-package-pro
description: Reviews Swift Package Manager libraries for public API design, module organization, dependency hygiene, and modern SPM features. Use when reading, writing, or reviewing Swift packages.
license: MIT
metadata:
  author: Kelvin Kosbab
  version: "1.0"
---

Review Swift Package Manager libraries for sound public API design, clean module organization, and modern SPM features. Report only genuine problems - do not nitpick or invent issues.

Review process:

1. Validate `Package.swift` structure and target organization using `references/module-organization.md`.
1. Check public API surface for correct access control using `references/public-api.md`.
1. Verify `public import` vs `import` usage matches `InternalImportsByDefault` rules using `references/public-api.md`.
1. Check resource handling for `.process` vs `.copy` correctness using `references/resources.md`.
1. Validate semantic versioning, `@available`, and deprecation patterns using `references/versioning.md`.
1. Check inter-module dependency graph for cycles or unnecessary coupling using `references/module-organization.md`.

If doing a partial review, load only the relevant reference files.


## Core Instructions

- Target Swift 6.0 or later with `.swiftLanguageMode(.v6)`.
- Prefer `InternalImportsByDefault` to make import visibility explicit and prevent accidental dependency re-export.
- Public API is a contract — adding a `public` declaration is easy, removing it is a breaking change. Default to `internal`.
- Each module should have a single, well-defined responsibility. Flag modules that mix unrelated concerns.
- Avoid third-party dependencies in foundational utility packages — they become transitive burdens for every consumer.
- Use `path:` parameters in `Package.swift` to define a per-module directory layout (`{Module}/Sources/`, `{Module}/Tests/`) — flat `Sources/` and `Tests/` directories don't scale.


## Output Format

Organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated.
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary of the most impactful changes to make first.

Example output:

### CoreUI/Sources/Spacing.swift

**Line 7: Unnecessary `public import` — `Foundation` types do not appear in this file's public API.**

```swift
// Before
public import Foundation

// After
import Foundation
```

### Package.swift

**Line 42: Target uses flat `Sources/Foo` path — prefer per-module directory layout.**

```swift
// Before
.target(name: "Foo", path: "Sources/Foo")

// After
.target(name: "Foo", path: "Foo/Sources")
```

### Summary

1. **Public API hygiene (high):** Three files mark `public import Foundation` unnecessarily — change to `import` to silence compiler warnings.
2. **Organization (medium):** `Package.swift` uses flat layout — migrate to per-module directories for scalability.

End of example.


## References

- `references/module-organization.md` — Target structure, per-module directory layout, helper functions, dependency graphs.
- `references/public-api.md` — Access control, `public import` vs `import`, `InternalImportsByDefault`, API stability.
- `references/resources.md` — Bundle resources, `.process` vs `.copy`, `Bundle.module`, SPM limitations (.xcdatamodeld).
- `references/versioning.md` — Semantic versioning, `@available`, `@_spi`, deprecation, breaking change checklist.
