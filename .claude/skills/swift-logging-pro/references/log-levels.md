# Log Levels

`os.Logger` has 5 levels. Use the right one for the situation.

## `.debug`

**Use for:** Verbose information useful only during active debugging.

```swift
logger.debug("Cache lookup for key \(key, privacy: .public): hit=\(hit, privacy: .public)")
logger.debug("Parsed body length: \(length, privacy: .public)")
```

- Not persisted to disk by default.
- Stripped from release builds in some configurations.
- High volume — fine to use liberally.

## `.info`

**Use for:** Normal events worth recording but not interesting after the fact.

```swift
logger.info("Loaded \(count, privacy: .public) records")
logger.info("Started background sync")
```

- Persisted briefly.
- Visible by default in Console.app.

## `.notice` (default)

**Use for:** Events that should be persisted longer and reviewed during diagnostics.

```swift
logger.notice("User signed in")
logger.notice("Migration completed: schema v\(version, privacy: .public)")
logger.notice("Configuration changed: \(setting, privacy: .public)=\(value, privacy: .public)")
```

- This is the default level — `logger.log(...)` without a method name uses `.notice`.
- Persisted for the system retention duration (usually long).

## `.error`

**Use for:** Recoverable failures that prevented an operation from succeeding.

```swift
logger.error("Network request failed: \(error.localizedDescription, privacy: .private)")
logger.error("Failed to write cache file: \(error.localizedDescription, privacy: .private)")
logger.error("Sync skipped — no connectivity")
```

- Always persisted.
- Indexed for crash and diagnostic reports.
- Use for things that went wrong but the app continued.

## `.fault`

**Use for:** Programmer errors and conditions that should never occur.

```swift
logger.fault("Encountered unexpected nil where presence was guaranteed")
logger.fault("Invariant violated: count=\(count, privacy: .public) when expected ≥ 0")
```

- Always persisted, with the highest priority.
- Indicates a bug, not a runtime condition.
- Often paired with `assertionFailure(...)` or `precondition(...)`.

Don't use `.fault` for expected runtime errors (like network failures) — that's what `.error` is for.

## Quick decision tree

```
Is it a programmer bug? ───────────────────────► .fault
Is it a recoverable failure?  ─────────────────► .error
Is it an event worth persisting and reviewing?─► .notice
Is it a normal event with low review value? ───► .info
Is it noisy debugging output? ─────────────────► .debug
```

## Performance cost

All `os.Logger` calls are cheap — the message is not formatted unless someone reads it. Don't optimize logging at the expense of clarity.

The exception is constructing expensive arguments:

```swift
// ❌ expensiveDescription() runs even if log isn't captured
logger.debug("State: \(expensiveDescription(), privacy: .public)")

// ✅ Hidden behind a check
if Logger.isDebugLevelEnabled {
    logger.debug("State: \(expensiveDescription(), privacy: .public)")
}
```

(Note: `os.Logger` doesn't have a public `isXLevelEnabled` API; use this pattern only when the cost is significant.)
