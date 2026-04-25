# Privacy Markers

## The default is private

Every interpolated value in an `os.Logger` call is `private` by default — the system redacts it in production logs:

```swift
logger.info("Loaded user \(userId)")
// In production: "Loaded user <private>"
// During development (debugger attached): "Loaded user 12345"
```

This is the right default for safety. Override only when you've thought about it.

## `.public` — for non-sensitive values

Mark values `.public` only when they're safe to log:

```swift
// ✅ Safe — no PII
logger.info("Cache hit rate: \(rate, privacy: .public)")
logger.info("Status: \(status, privacy: .public)")
logger.info("Loaded \(count, privacy: .public) items in \(duration, privacy: .public)s")
logger.info("Endpoint: \(endpoint.path, privacy: .public)")
```

Generally safe to mark `.public`:

- Counts, durations, sizes
- Status codes, enum values
- Fixed paths/endpoints (not query params with IDs)
- Boolean flags

## `.private` — for sensitive but loggable values

Use `.private` (or omit, since it's the default) for values that should be redacted in production but visible during development:

```swift
logger.info("Loaded user \(userId, privacy: .private)")
logger.info("Email: \(emailAddress, privacy: .private)")
```

## `.sensitive` — for values that should never appear in plaintext

Use `.sensitive` for highly sensitive data — these are redacted even during development without explicit profiles:

```swift
logger.info("Token received: \(authToken, privacy: .sensitive)")
```

## Hashing for correlation without exposure

To correlate log entries across sessions without revealing the value, use the hash mask:

```swift
logger.info("User session: \(userId, privacy: .private(mask: .hash))")
// Logs a stable hash of the value, so the same user appears with the same hash
```

Useful for tracking user-specific issues without exposing the actual ID.

## What never to log — even with .public

- **Passwords, API keys, OAuth tokens** — never log, even masked.
- **Credit card numbers, SSNs, bank account numbers** — same.
- **Full email addresses** in plaintext (mark `.private` at minimum).
- **Geographic coordinates** (mark `.private`).
- **Anything covered by GDPR/CCPA/HIPAA** in your jurisdiction.

The rule: if a screenshot of the log would be a security incident, don't log it as `.public`.

## Privacy in error logging

`Error.localizedDescription` may contain PII (e.g., URLs with user IDs). Treat it as private:

```swift
logger.error("Network error: \(error.localizedDescription, privacy: .private)")
```

For safer error logging, log the error type and a synthetic description:

```swift
logger.error("Network error: \(String(describing: type(of: error)), privacy: .public)")
```

## Compile-time enforcement

The `os.Logger` interpolation API is implemented with a custom string-interpolation type. The compiler checks that you provide a `privacy:` argument when interpolating non-`StaticString` values into log messages — at least for newer SDKs.

If you forget the privacy marker, the compiler emits a warning. Treat these as errors during code review.
