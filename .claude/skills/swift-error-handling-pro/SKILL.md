---
name: swift-error-handling-pro
description: Reviews Swift error handling for modern patterns including typed throws, Result vs throws, LocalizedError conformance, and async error propagation. Use when writing or reviewing Swift error types and throwing functions.
license: MIT
metadata:
  author: Kelvin Kosbab
  version: "1.0"
---

Review Swift error handling for correctness, modern API usage, and clear error semantics. Report only genuine problems - do not nitpick or invent issues.

Review process:

1. Check error type definitions for `LocalizedError`, `Equatable`, and `Sendable` conformance using `references/error-types.md`.
1. Evaluate whether typed throws (Swift 6.0+) would clarify the API using `references/typed-throws.md`.
1. Validate Result vs throws choice for the API style using `references/result-vs-throws.md`.
1. Check async error propagation patterns using `references/async-errors.md`.
1. Flag swallowed errors (catch blocks that ignore errors silently).

If doing a partial review, load only the relevant reference files.


## Core Instructions

- Target Swift 6.0 or later — typed throws is available and should be considered for library code.
- Prefer `throws` over `Result` in modern async code — `async throws` reads more naturally than returning a `Result`.
- Error types should conform to `Sendable` so they can cross isolation boundaries safely.
- Public error types should conform to `LocalizedError` and provide `errorDescription` for user-facing strings.
- Never use `try!` or `try?` to silence errors that could meaningfully be handled or surfaced.
- Avoid `catch { }` blocks that swallow the error — at minimum, log it.
- Don't wrap errors in nested types unnecessarily — flatten error hierarchies where possible.


## Output Format

Organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated.
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary of the most impactful changes to make first.

Example output:

### CoreStorage/Sources/CodableStore/DiskBackedJSONCodableStoreError.swift

**Line 12: Public error type should conform to `LocalizedError` for user-facing strings.**

```swift
// Before
public enum DiskBackedJSONCodableStoreError: Error {
    case readFailed
    case writeFailed
}

// After
public enum DiskBackedJSONCodableStoreError: LocalizedError {
    case readFailed
    case writeFailed

    public var errorDescription: String? {
        switch self {
        case .readFailed: "Failed to read from disk."
        case .writeFailed: "Failed to write to disk."
        }
    }
}
```

**Line 34: Use typed throws for clearer API contract.**

```swift
// Before
public func read() throws -> Data

// After
public func read() throws(DiskBackedJSONCodableStoreError) -> Data
```

### Summary

1. **API clarity (high):** Public error types lack `LocalizedError` conformance, making error messages opaque to consumers.
2. **Type safety (medium):** Throwing functions could use typed throws for compile-time error documentation.

End of example.


## References

- `references/error-types.md` — Defining error enums, `LocalizedError`, `Equatable`, `Sendable` conformance.
- `references/typed-throws.md` — Swift 6.0 typed throws syntax, when to use, performance benefits, migration.
- `references/result-vs-throws.md` — When to use `Result<T, E>` vs `throws`, async considerations, callback APIs.
- `references/async-errors.md` — Error handling in `async`/`await`, propagation through `TaskGroup`, cancellation errors.
