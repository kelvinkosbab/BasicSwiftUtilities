# Public API Design

## Access control defaults

- Default to `internal` (the Swift default). Mark `public` only when consumers need it.
- A type can be `public` while its initializer is `internal` — control instantiation separately.
- Use `private(set) public var` for read-only public state.
- `fileprivate` is rarely needed — usually `private` (same scope) or `internal` (same module) is correct.

## `public import` vs `import` (with `InternalImportsByDefault`)

When `.enableUpcomingFeature("InternalImportsByDefault")` is set:

- All imports default to `internal` — they are NOT re-exported to consumers.
- Use `public import` only when types from that framework appear in your module's **public** API signatures.
- If you mark `public import` unnecessarily, the compiler emits a warning.
- If your public API uses a type from a framework you imported as `internal`, the compiler emits an error.

### Examples

```swift
// File only uses Foundation internally — keep import as internal.
import Foundation

internal struct PrivateImpl {
    let url: URL  // URL used internally only
}
```

```swift
// File exposes Foundation types in public API — must be public import.
public import Foundation

public struct PublicAPI {
    public let url: URL  // URL used in public API
}
```

## API stability rules

Adding `public` is easy. **Removing `public` is a breaking change.** Be conservative:

- New types/methods: start `internal`. Promote to `public` when an external consumer asks.
- Avoid `public` on types that are still in flux.
- For experimental APIs, use `@_spi(Experimental)` to mark them as opt-in:

```swift
@_spi(Experimental) public func experimentalFeature() { }
```

Consumers must explicitly opt in:

```swift
@_spi(Experimental) import MyModule
```

## Avoid leaking implementation types

If a public method returns or accepts an internal type, the type must also be public — or the API can't be called. Common leak patterns:

- Returning a `some Protocol` where the protocol is internal.
- Accepting a callback `(InternalType) -> Void`.
- Public properties of internal types.

When in doubt: minimize the public surface area.

## Interface vs implementation modules

For larger packages, consider splitting protocols (interface) from implementations:

```
MyServiceInterface  →  defines the protocol
MyServiceImpl       →  implements the protocol, depends on Interface
MyServiceMocks      →  mock implementations for tests
```

Consumers depend only on the interface module, allowing implementations to be swapped at the binary level.
