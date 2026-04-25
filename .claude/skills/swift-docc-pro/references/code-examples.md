# Code Examples in Documentation

## Code fences

Use triple-backtick fences with the language hint:

````swift
/// Usage:
/// ```swift
/// let widget = Widget(name: "foo")
/// widget.frobnicate()
/// ```
public struct Widget { }
````

Always specify `swift` as the language hint — DocC will syntax-highlight.

## Keep examples runnable

Examples should compile and behave as documented. Common pitfalls:

- Don't reference symbols that don't exist (typos in property names).
- Don't omit required imports when they affect what's shown.
- Don't show outdated API usage.

If the example references types from other modules, mention them in prose:

```swift
/// Usage (requires `import Core`):
/// ```swift
/// let logger = SwiftLogger(subsystem: "com.example", category: "App")
/// logger.info("Hello")
/// ```
```

## Show realistic input

Avoid placeholder names like `foo`, `bar`, `someVar` in examples. Use names that suggest the actual use case:

```swift
// ❌ Generic
/// ```swift
/// let x = retry(operation: foo)
/// ```

// ✅ Realistic
/// ```swift
/// let result = try await asyncRetry(max: 3, strategy: .exponential) {
///     try await fetchUserProfile(id: userID)
/// }
/// ```
```

## Multi-step examples

For workflows, number the steps in prose and show progressive code:

```swift
/// Setting up a toast container:
///
/// 1. Create a `ToastApi` instance:
///    ```swift
///    let toastApi = ToastApi(options: ToastOptions(position: .top))
///    ```
///
/// 2. Attach it to your view hierarchy:
///    ```swift
///    ContentView()
///        .toastableContainer(toastApi: toastApi)
///    ```
///
/// 3. Show toasts from anywhere:
///    ```swift
///    toastApi.show(title: "Saved!")
///    ```
```

## Indentation in comments

Code inside `///` lines must be properly indented. Each line starts with `/// ` and then the content:

```swift
/// ```swift
/// if let value {
///     print(value)
/// }
/// ```
```

NOT:

```swift
/// ```swift
///if let value {
///    print(value)
///}
/// ```
```

## Avoiding stale examples

When you change an API, search for code examples in doc comments that may need updating:

```bash
grep -rn "old_function_name" --include="*.swift" -A 5
```

Outdated examples are worse than no examples — they mislead readers.
