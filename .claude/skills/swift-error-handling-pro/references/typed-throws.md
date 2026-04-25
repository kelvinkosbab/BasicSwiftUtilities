# Typed Throws (Swift 6.0+)

## Syntax

Swift 6.0 introduced typed throws:

```swift
// Untyped (any Error)
func fetch() throws -> Data

// Typed (only NetworkError)
func fetch() throws(NetworkError) -> Data
```

The same syntax works for `async`, generics, etc.:

```swift
func fetch() async throws(NetworkError) -> Data
func process<T>(_ items: [T]) throws(ProcessingError) -> [T]
```

## When to use typed throws

✅ **Good fits:**

- Library APIs where the error type is part of the contract.
- Functions with a small, well-known set of errors.
- Functions where consumers will switch over the error.

❌ **Avoid for:**

- High-level APIs where many error sources flow through (typed throws becomes restrictive).
- Functions calling many other throwing APIs — you'd have to wrap each one.
- App-level code where the error eventually becomes "show a generic error to the user".

## The `throws(Never)` pattern

`throws(Never)` is equivalent to non-throwing — useful in generic contexts:

```swift
func process<E: Error>() throws(E) -> Result {
    // ...
}

// Caller can opt out of throwing:
let result = try process() as Result  // E inferred as Never
```

## Migration: untyped → typed

Adding typed throws to an existing untyped function is a **non-breaking source change** (callers don't change), but it tightens the contract:

```swift
// Before
public func fetch() throws -> Data

// After (callers don't need to change)
public func fetch() throws(NetworkError) -> Data
```

If the function previously threw multiple unrelated error types, you'll need to wrap them in a single error type first.

## Performance benefits

Typed throws let the compiler avoid existential boxing of errors, making throws cheaper. This matters most in tight loops.

## Interoperation with untyped throws

A typed-throws function can be called from untyped contexts — the typed error is implicitly upcast to `any Error`:

```swift
do {
    try fetch()  // throws(NetworkError) function
} catch {
    // `error` is `any Error` here, but actually NetworkError
}
```

To preserve the type, switch on the specific error:

```swift
do {
    try fetch()
} catch let error as NetworkError {
    // `error` is NetworkError
    switch error {
    case .connectionFailed: ...
    case .invalidStatus(let code): ...
    }
}
```

Or use typed catch:

```swift
do throws(NetworkError) {
    try fetch()
} catch {
    // `error` is NetworkError automatically
}
```

## Common pitfalls

- **Over-constraining APIs**: typed throws is a contract — adding new error cases to your error enum is non-breaking, but throwing a *different* error type from a typed-throws function is breaking. Plan your error type carefully.
- **Generic propagation**: if your function calls another typed-throws function with a different error type, you must convert:
  ```swift
  func outer() throws(MyError) {
      do {
          try inner()  // throws(OtherError)
      } catch {
          throw MyError.wrapped(error)
      }
  }
  ```
