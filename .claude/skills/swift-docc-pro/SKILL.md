---
name: swift-docc-pro
description: Reviews and improves Swift documentation comments (DocC) for correctness, completeness, and clarity. Use when writing or reviewing public API documentation in Swift packages.
license: MIT
metadata:
  author: Kelvin Kosbab
  version: "1.0"
---

Review Swift documentation comments for completeness, accuracy, and DocC compatibility. Report only genuine problems - do not nitpick or invent issues.

Review process:

1. Verify all `public` declarations have documentation comments using `references/comment-syntax.md`.
1. Validate parameter, return, and throws documentation completeness using `references/comment-syntax.md`.
1. Check symbol linking syntax (``Type``) using `references/symbol-linking.md`.
1. Validate code example formatting using `references/code-examples.md`.
1. Suggest `## Topics` organization for types with many members using `references/topics.md`.

If doing a partial review, load only the relevant reference files.


## Core Instructions

- All `public` declarations should have at least a one-line summary comment.
- Use triple-slash `///` for declaration documentation, not `/** */` block comments.
- Parameter, return, and throws documentation must match the actual signature exactly.
- Code examples in doc comments should be valid, compilable Swift.
- Use double-backtick symbol references (``MyType``) so DocC creates clickable links.
- Markdown links to external documentation are encouraged — link to Apple's docs whenever referencing system APIs.
- Don't repeat the obvious — `public init()` doesn't need "Initializes the type." Add docs only when they convey useful information.


## Output Format

Organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated.
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary of the most impactful changes to make first.

Example output:

### Core/Sources/Retry/AsyncRetry.swift

**Line 23: Missing `- Throws:` documentation for throwing function.**

```swift
// Before
/// Retries an async operation with the configured strategy.
/// - Parameter operation: The async work to retry.
/// - Returns: The successful result of the operation.
public func asyncRetry<T>(
    _ operation: () async throws -> T
) async throws -> T

// After
/// Retries an async operation with the configured strategy.
/// - Parameter operation: The async work to retry.
/// - Returns: The successful result of the operation.
/// - Throws: The last error thrown by `operation` if all retry attempts are exhausted.
public func asyncRetry<T>(
    _ operation: () async throws -> T
) async throws -> T
```

**Line 45: Use double-backtick to link to symbol instead of single backtick.**

```swift
// Before
/// See `RetryStrategy` for available strategies.

// After
/// See ``RetryStrategy`` for available strategies.
```

### Summary

1. **Completeness (high):** 4 throwing public functions in `Core/Sources/Retry/` are missing `- Throws:` documentation.
2. **DocC linking (medium):** Several symbol references use single backticks — change to double for proper linking.

End of example.


## References

- `references/comment-syntax.md` — `///` triple-slash syntax, `- Parameter`, `- Returns`, `- Throws`, `- Note`, `- Warning`.
- `references/symbol-linking.md` — Double-backtick symbol references, cross-module linking, member references.
- `references/code-examples.md` — Code blocks in doc comments, language hints, runnable examples.
- `references/topics.md` — `## Topics` sections, grouping related symbols, top-level overviews.
