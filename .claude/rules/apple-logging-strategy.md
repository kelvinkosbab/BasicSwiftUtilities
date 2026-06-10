---
description: Logging strategy for Apple platforms — os.Logger / OSLog over print/NSLog, subsystem/category conventions, privacy markers, log-level discipline, signposts, what never to log
globs: "**/*.swift"
---

# Apple Logging Strategy

`print()` is for scripts and tests, not shipping apps. Production logging on Apple platforms goes through the unified logging system (`os.Logger` / `OSLog`) — it's structured, level-aware, privacy-aware, low-overhead, and viewable in Console.app and the `log` CLI. This rule pins the always-on conventions; for a deep file-by-file review of logging code, invoke the **`swift-logging-pro`** skill.

## Use `Logger`, Not `print` / `NSLog`

- **`Logger` (os.Logger, iOS 14+/macOS 11+)** is the modern API. Use it for all production logging.
- **Never `print()` in shipping code** — it's unstructured, always-on (no level filtering), strips no privacy, and is invisible in Console.app's structured view. Acceptable only in tests, SwiftPM plugins, and CLI tools.
- **Never `NSLog`** in new code — it's synchronous, slow, and predates the privacy model. Migrate it to `Logger`.
- **`OSLog` (the older `os_log` C-ish API)** still works but `Logger` is the ergonomic Swift surface; prefer it.

## Subsystem + Category Conventions

```swift
import OSLog

// One Logger per category — usually a static let on the type that uses it.
private let logger = Logger(subsystem: "com.example.MyApp", category: "Networking")
```

- **`subsystem`** is the reverse-DNS bundle identifier (or a stable app-wide constant). Same value across the whole app.
- **`category`** names the subsystem-internal area: `Networking`, `Persistence`, `Auth`, `UI`. One `Logger` per category lets you filter in Console.app by category.
- **Hold the `Logger` as a `static let`** (or a `private let` at file scope), not constructed per call. Construction is cheap but a stable instance is the convention and keeps category strings consistent.
- **Centralize the subsystem constant** so a typo doesn't fragment your logs across two near-identical subsystem strings.

## Privacy Markers — the Part People Get Wrong

The unified logging system redacts interpolated values **by default** (`<private>`) for dynamic strings. You opt into visibility explicitly:

```swift
logger.info("Fetched \(items.count, privacy: .public) items for user \(userID, privacy: .private)")
logger.debug("Token prefix \(token.prefix(4), privacy: .private(mask: .hash))")
```

- **`.public`** — non-sensitive values safe to show in logs (counts, status codes, durations, enum cases, feature flags). Mark these explicitly; otherwise they're redacted and your logs are useless.
- **`.private`** (the default for dynamic values) — sensitive-but-loggable (user IDs, file paths). Redacted in sysdiagnose/device logs unless the debugger is attached.
- **`.private(mask: .hash)`** — log a stable hash so you can correlate occurrences without exposing the value. The right choice for identifiers you need to *match* but not *read*.
- **Static string literals are always public** — `logger.info("Sync started")` needs no marker. Only *interpolated* values get redacted.
- **Never mark secrets `.public`** — tokens, passwords, keys, PII. If you wouldn't paste it in a bug report, it's not `.public`.

## Log Levels — When Each

| Level | Persisted? | Use for |
|-------|-----------|---------|
| `.debug` | No (memory only, debug builds) | Verbose developer detail; gone in release. Cheapest. |
| `.info` | Not persisted by default | Helpful context not needed after the fact. |
| `.notice` (default) | Yes | Default level; things worth keeping (significant state changes). |
| `.error` | Yes | Recoverable errors — something went wrong but the app continues. |
| `.fault` | Yes | Programmer errors / unrecoverable conditions — bugs that should never happen. |

- **Match the level to severity**, not to "how much I want to see it right now." A `.fault` that fires routinely trains people to ignore faults.
- **`.debug` is free in release** — it compiles to a no-op-ish path and isn't persisted, so liberal `.debug` logging costs nothing shipped. Use it instead of commenting-out diagnostics.
- **`.error` / `.fault` are persisted and surfaced** in crash diagnostics — reserve them for genuine problems.

## Performance

- **Interpolation is lazy** — `Logger` uses `@autoclosure`, so `logger.debug("\(expensiveDescription())")` does **not** evaluate `expensiveDescription()` when the level is disabled. You don't need manual `if logLevelEnabled` guards.
- **Don't pre-build log strings** — `let msg = "..."; logger.debug("\(msg)")` defeats the lazy evaluation. Interpolate directly in the call.
- **Signposts for performance measurement** — use `OSSignposter` (`os_signpost`) for interval timing that shows up in Instruments, not `Logger` + manual timestamps:

  ```swift
  let signposter = OSSignposter(subsystem: "com.example.MyApp", category: .pointsOfInterest)
  let state = signposter.beginInterval("Image decode")
  …
  signposter.endInterval("Image decode", state)
  ```

## What Never To Log

- **Secrets** — tokens, API keys, passwords, refresh tokens, signing keys. Not even `.private`-marked; just don't.
- **PII beyond what you need** — full names, emails, precise location, device identifiers. Log a hashed correlation ID instead.
- **Whole request/response bodies** — they carry auth headers and personal data. Log status + a correlation ID; gate body dumps behind a debug-only flag.
- **Inside tight loops at `.notice`+** — floods the persistent store. Use `.debug` for per-iteration detail.

## Retrieving Logs

- **Console.app** — live + historical, filter by subsystem/category/level. The primary tool.
- **`log` CLI** — `log stream --predicate 'subsystem == "com.example.MyApp"'` for live; `log show --last 1h` for historical.
- **`OSLogStore`** (in-app) — read the app's own logs programmatically to attach to a bug report. The supported way to ship logs with user feedback.
- **Don't roll your own file logger** to "save logs" unless you have a specific need OSLogStore can't meet — you lose the privacy model and the structured query surface.

## Common Pitfalls

- **`print()` in production** — unstructured, unfilterable, no privacy. The most common smell.
- **Forgetting `privacy: .public`** on values you need to see — your release logs show `<private>` for everything useful.
- **Marking sensitive values `.public`** to "make logs readable" — leaks PII/secrets into sysdiagnose.
- **One giant subsystem, no categories** — you can't filter; every log is a needle in one haystack.
- **`Logger` constructed per call with inline strings** — works, but fragments categories on typos. Use a `static let`.
- **`.error`/`.fault` for non-errors** — desensitizes the team; real faults get ignored.
- **Pre-interpolating** (`logger.debug(message)` where `message` was already built) — defeats lazy evaluation; pays the string cost even when disabled.

## Patterns to Follow

```swift
import OSLog

extension Logger {
    // App-wide subsystem constant — one place, no typos.
    private static let subsystem = "com.example.MyApp"
    static let networking = Logger(subsystem: subsystem, category: "Networking")
    static let auth       = Logger(subsystem: subsystem, category: "Auth")
}

func fetch(userID: String) async {
    Logger.networking.debug("Starting fetch")                       // free in release
    do {
        let items = try await api.items(for: userID)
        Logger.networking.info("Fetched \(items.count, privacy: .public) items for \(userID, privacy: .private(mask: .hash))")
    } catch {
        Logger.networking.error("Fetch failed: \(error.localizedDescription, privacy: .public)")
    }
}
```
