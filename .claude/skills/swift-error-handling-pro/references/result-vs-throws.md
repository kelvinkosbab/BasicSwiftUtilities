# Result vs throws

## TL;DR

- **Modern code → use `throws`** (sync) or `async throws` (async).
- **`Result` is a tool for specific cases**, not a general replacement for `throws`.

## When throws is the right choice

Almost always, in modern Swift:

```swift
public func fetch() async throws -> Data
```

The caller writes idiomatic code:

```swift
do {
    let data = try await fetch()
    process(data)
} catch {
    handle(error)
}
```

## When Result is the right choice

`Result<Success, Failure>` shines when:

### 1. Storing the outcome of an operation

When you need to capture success/failure as a value to inspect or pass around later:

```swift
struct PendingOperation {
    let id: UUID
    var result: Result<Data, NetworkError>?  // nil while in flight
}
```

### 2. Multiple independent results

When you have a collection of independent operations and need each outcome:

```swift
let results: [Result<Data, NetworkError>] = await withTaskGroup(of: Result<Data, NetworkError>.self) { group in
    for url in urls {
        group.addTask {
            do {
                return .success(try await fetch(url))
            } catch let error as NetworkError {
                return .failure(error)
            }
        }
    }
    var collected: [Result<Data, NetworkError>] = []
    for await result in group {
        collected.append(result)
    }
    return collected
}
```

### 3. Bridging callback-based APIs

When wrapping a legacy callback API with `withCheckedThrowingContinuation`, you may temporarily handle a `Result`:

```swift
func legacyFetch(completion: @escaping (Result<Data, Error>) -> Void) { ... }

func modernFetch() async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        legacyFetch { result in
            continuation.resume(with: result)
        }
    }
}
```

`continuation.resume(with: result)` accepts a `Result` directly — convenient.

## When NOT to use Result

❌ **Don't use `Result` to avoid `throws`** in async functions:

```swift
// ❌ Awkward
func fetch() async -> Result<Data, NetworkError> {
    do {
        let data = try await session.data(from: url).0
        return .success(data)
    } catch {
        return .failure(.connectionFailed)
    }
}

// ✅ Idiomatic
func fetch() async throws -> Data {
    try await session.data(from: url).0
}
```

The `Result` version forces every caller to switch on the result, even when they just want to propagate the error.

❌ **Don't use `Result` to encode "expected" failures.** If a "failure" is part of the normal flow (e.g., a search returns no results), use `Optional` or a domain-specific type:

```swift
// ❌ Awkward
func findUser(id: UUID) async -> Result<User, UserError>

// ✅ Better
func findUser(id: UUID) async throws -> User?  // nil = not found, throws = real error
```

## Converting between Result and throws

Result → throws (`get()`):

```swift
let data = try result.get()
```

throws → Result (`init(catching:)`):

```swift
let result = Result { try someThrowingFunction() }
let asyncResult = await Result { try await someAsyncThrowingFunction() }
```

## Typed throws vs Result

Swift 6 typed throws covers most cases where you'd reach for `Result<T, SpecificError>`:

```swift
// Old style
func fetch() async -> Result<Data, NetworkError>

// Modern style
func fetch() async throws(NetworkError) -> Data
```

Typed throws gives you the same compile-time error type guarantees with idiomatic syntax.
