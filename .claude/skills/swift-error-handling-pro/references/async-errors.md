# Error Handling in Async Code

## Propagation through await

Errors propagate through `await` naturally. Mark the function `throws`:

```swift
func loadUser() async throws -> User {
    let data = try await session.data(from: url).0  // error propagates here
    return try JSONDecoder().decode(User.self, from: data)
}
```

## TaskGroup error semantics

In a `withThrowingTaskGroup`, the **first error thrown by any child task** is rethrown by the group, and **all sibling tasks are cancelled**:

```swift
try await withThrowingTaskGroup(of: Data.self) { group in
    for url in urls {
        group.addTask { try await fetch(url) }
    }

    for try await result in group {  // throws here on first failure
        process(result)
    }
}
// Once the group exits via throw, all remaining child tasks are cancelled.
```

If you want to collect partial results without aborting on first failure, wrap each child's work in a `Result`:

```swift
let results = await withTaskGroup(of: Result<Data, Error>.self) { group in
    for url in urls {
        group.addTask {
            do {
                return .success(try await fetch(url))
            } catch {
                return .failure(error)
            }
        }
    }
    var collected: [Result<Data, Error>] = []
    for await r in group { collected.append(r) }
    return collected
}
```

## Cancellation throws CancellationError

When a task is cancelled and calls `try Task.checkCancellation()` or an async function that respects cancellation, it throws `CancellationError`:

```swift
do {
    try await longRunningWork()
} catch is CancellationError {
    // Task was cancelled — usually no need to log or alert
} catch {
    // Real failure — log/alert
}
```

Don't treat `CancellationError` as a real error — it's part of the cancellation contract.

## Don't swallow errors silently

```swift
// ❌ Bad
try? await fetch()

// ❌ Worse
do {
    try await fetch()
} catch {
    // ignored
}

// ❌ Still bad — swallowed but logged
do {
    try await fetch()
} catch {
    print("error: \(error)")  // not surfaced to user, no metrics
}

// ✅ Better — propagate or handle properly
do {
    try await fetch()
} catch {
    logger.error("Fetch failed: \(error.localizedDescription)")
    showAlert(message: error.localizedDescription)
}
```

`try?` is acceptable when:

- The error is genuinely informational and unrelated to correctness (e.g., best-effort cache cleanup).
- You're in a `defer` block where throwing isn't allowed.

## Async retry patterns

Wrap with retry when transient errors are expected:

```swift
func fetchWithRetry(maxAttempts: Int = 3) async throws -> Data {
    var lastError: Error?
    for attempt in 1...maxAttempts {
        do {
            return try await fetch()
        } catch {
            lastError = error
            if attempt < maxAttempts {
                try await Task.sleep(for: .seconds(pow(2.0, Double(attempt))))
            }
        }
    }
    throw lastError!
}
```

Always:

- Respect cancellation: a sleeping retry should be cancellable.
- Log each attempt failure for diagnosis.
- Cap the retry count to avoid infinite loops.

See `Core/Sources/Retry/AsyncRetry.swift` in this package for a production-grade retry implementation.

## Avoid `Task { ... }` that swallows errors

Detached tasks lose error propagation:

```swift
// ❌ Error vanishes
Task {
    try await dangerousOperation()
}

// ✅ Either handle or annotate why we don't care
Task {
    do {
        try await dangerousOperation()
    } catch {
        logger.error("Operation failed: \(error)")
    }
}
```

If the work is fire-and-forget, the error must still go somewhere — at least to logs.
