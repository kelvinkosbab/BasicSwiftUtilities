---
name: swift-logging-pro
description: Reviews Swift logging code using os.Logger and Loggable patterns for correct privacy markers, subsystem/category conventions, and appropriate log levels. Use when writing or reviewing logging code.
license: MIT
metadata:
  author: Kelvin Kosbab
  version: "1.0"
---

Review Swift logging code for correctness, privacy compliance, and consistent subsystem conventions. Report only genuine problems - do not nitpick or invent issues.

Review process:

1. Check `os.Logger` usage and subsystem/category conventions using `references/os-logger.md`.
1. Validate privacy markers on logged values using `references/privacy.md`.
1. Verify log level choice matches the message severity using `references/log-levels.md`.
1. Flag `print()` statements in production code (acceptable in tests, scripts).

If doing a partial review, load only the relevant reference files.


## Core Instructions

- Use `os.Logger` (modern API), not `OSLog` (legacy) or `print()` (no privacy, no levels, no subsystem filtering).
- Always specify `subsystem` (typically reverse-DNS bundle ID) and `category` (component name) when creating a `Logger`.
- All interpolated values default to `private` — explicitly mark with `.public` only when safe (e.g., status enums, fixed strings).
- Never log usernames, passwords, tokens, email addresses, or PII — even with `.public`.
- Use the appropriate level: `.debug` for development noise, `.info` for normal events, `.notice` for important events, `.error` for recoverable failures, `.fault` for programmer errors.
- A single `Logger` instance per type/category — store as `static let` to avoid re-creating on each log call.


## Output Format

Organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated.
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary of the most impactful changes to make first.

Example output:

### MyService.swift

**Line 18: Privacy violation — user identifier logged as `.public`.**

```swift
// Before
logger.info("Loaded user \(userId, privacy: .public)")

// After
logger.info("Loaded user \(userId, privacy: .private)")
```

**Line 34: Use `.error` level for recoverable failures, not `.info`.**

```swift
// Before
logger.info("Network request failed: \(error.localizedDescription)")

// After
logger.error("Network request failed: \(error.localizedDescription)")
```

**Line 45: `print()` statement in production code — replace with `Logger`.**

```swift
// Before
print("Cache miss for key \(key)")

// After
logger.debug("Cache miss for key \(key, privacy: .public)")
```

### Summary

1. **Privacy (high):** User-identifying data logged as `.public` on line 18 — change to `.private`.
2. **Severity (medium):** Recoverable failure logged at `.info` — should be `.error`.
3. **Modernization (low):** `print()` statement should use `Logger`.

End of example.


## References

- `references/os-logger.md` — `os.Logger` basics, subsystem/category conventions, instance creation patterns.
- `references/privacy.md` — `.public`, `.private`, `.sensitive` markers, redaction, what never to log.
- `references/log-levels.md` — `.debug`, `.info`, `.notice`, `.error`, `.fault` semantics, performance impact.
