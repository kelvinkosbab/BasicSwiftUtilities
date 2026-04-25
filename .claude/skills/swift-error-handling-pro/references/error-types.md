# Defining Error Types

## Use enums for structured errors

Errors should be enums with associated values for context:

```swift
public enum NetworkError: Error {
    case connectionFailed
    case invalidStatus(code: Int)
    case decodingFailed(underlying: Error)
}
```

Avoid `String`-based errors or single-case enums — they lose information.

## Conform to `Sendable`

In Swift 6, errors crossing isolation boundaries must be `Sendable`. Most errors should be:

```swift
public enum NetworkError: Error, Sendable {
    case connectionFailed
    case invalidStatus(code: Int)
}
```

Enums with `Sendable` associated values are automatically `Sendable`. The compiler will tell you if a case has a non-`Sendable` payload.

If you need to wrap a non-`Sendable` error (like a system NSError), document why:

```swift
public enum NetworkError: Error, @unchecked Sendable {
    case underlying(NSError)  // NSError is not Sendable but is thread-safe
}
```

(`@unchecked Sendable` should be rare — prefer to extract the relevant info into `Sendable` fields.)

## Conform to `LocalizedError` for user-facing messages

Public error types should provide `errorDescription` so consumers get useful messages from `error.localizedDescription`:

```swift
public enum NetworkError: LocalizedError, Sendable {
    case connectionFailed
    case invalidStatus(code: Int)

    public var errorDescription: String? {
        switch self {
        case .connectionFailed:
            "Could not connect to the server."
        case .invalidStatus(let code):
            "Server returned status \(code)."
        }
    }
}
```

Other `LocalizedError` properties:

- `failureReason` — the underlying cause
- `recoverySuggestion` — what the user can do
- `helpAnchor` — a help-system anchor

## Conform to `Equatable` for testing

Tests benefit from comparing errors with `#expect(error == .connectionFailed)`. Make errors `Equatable` when feasible:

```swift
public enum NetworkError: Error, Sendable, Equatable {
    case connectionFailed
    case invalidStatus(code: Int)
}
```

Enums with `Equatable` associated values get synthesized `Equatable`. If a case has a non-`Equatable` payload (like `Error`), implement `==` manually:

```swift
public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.connectionFailed, .connectionFailed): true
    case let (.invalidStatus(a), .invalidStatus(b)): a == b
    default: false
    }
}
```

## Avoid deep error hierarchies

Don't nest error types unnecessarily:

```swift
// ❌ Over-engineered
public enum AppError: Error {
    case network(NetworkError)
}
public enum NetworkError: Error {
    case http(HTTPError)
}
public enum HTTPError: Error {
    case status(StatusError)
}

// ✅ Flat and direct
public enum AppError: Error {
    case noConnection
    case httpStatus(Int)
    case decodingFailed
}
```

If you do need to wrap, the wrapper should add information (context, location), not just rename.

## Document what throws

In doc comments, list possible error types and conditions:

```swift
/// Fetches the user profile.
///
/// - Throws: ``NetworkError/connectionFailed`` if the device is offline.
///           ``NetworkError/invalidStatus(code:)`` if the server returns non-2xx.
///           ``NetworkError/decodingFailed(underlying:)`` if the response is malformed.
public func fetchProfile(id: UUID) async throws -> Profile
```

With Swift 6 typed throws, the compiler can enforce this:

```swift
public func fetchProfile(id: UUID) async throws(NetworkError) -> Profile
```
