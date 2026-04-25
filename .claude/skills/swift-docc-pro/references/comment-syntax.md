# Documentation Comment Syntax

## Triple-slash, not block comments

DocC recognizes `///` triple-slash comments. Avoid `/** */` block comments — they work but `///` is the convention.

```swift
/// A widget that frobnicates the input.
public struct Widget { }
```

## Summary, discussion, fields

The first line is the summary (shown in code completion). Subsequent paragraphs are the discussion (shown on the type's page).

```swift
/// Retries an async operation according to the configured strategy.
///
/// This function will repeatedly invoke `operation` until it either succeeds or
/// the strategy's retry budget is exhausted. Backoff between attempts is
/// determined by the strategy.
///
/// - Parameters:
///   - max: The maximum number of attempts.
///   - strategy: The backoff strategy controlling delays between attempts.
///   - operation: The async work to retry.
/// - Returns: The successful result of the operation.
/// - Throws: The last error thrown by `operation` if all retry attempts are exhausted.
public func asyncRetry<T>(
    max: Int,
    strategy: RetryStrategy,
    _ operation: () async throws -> T
) async throws -> T
```

## Field tags

| Tag | Use for |
|-----|---------|
| `- Parameter name:` | Single parameter |
| `- Parameters:` (then nested `- name:`) | Multiple parameters |
| `- Returns:` | Return value description |
| `- Throws:` | What errors are thrown and when |
| `- Note:` | Important sidebar information |
| `- Warning:` | Critical caveat the caller must know |
| `- Important:` | Slightly less severe than Warning |
| `- Precondition:` | What must be true before calling |
| `- Postcondition:` | What is guaranteed after calling |
| `- SeeAlso:` | Related symbols (use double-backtick links) |

## Skip the obvious

Don't document what's obvious from the signature:

```swift
// ❌ Bad — adds nothing
/// Initializes a Widget.
public init()

// ✅ Good — document only when there's something useful to say
/// Initializes a Widget with the default configuration.
///
/// Equivalent to `Widget(config: .default)`.
public init()
```

## Format strings within comments

- Use single backticks for inline code: `` `Widget` ``.
- Use double backticks for symbol links: ```` ``Widget`` ```` (DocC creates a link).
- Use code fences for multi-line examples (see code-examples.md).
- Use `**bold**` and `*italic*` for emphasis.
- Lists work with `-` or `1.`.

## Markdown extensions

DocC supports standard CommonMark plus:

- Symbol references: ```` ``Type/method(_:)`` ````
- Asset references: `![Description](image-name)` (asset must be in `.docc` catalog)
- Link references: `[Apple's docs](https://developer.apple.com/...)`

## Article and overview pages

For complex types, create a `.docc` catalog with overview pages:

```
MyModule/
    Sources/
        MyModule.docc/
            MyModule.md          # Top-level overview
            UsingWidgets.md      # Article
            Resources/
                widget.png
```

Articles use `# Title` and can reference symbols:

```markdown
# Using Widgets

A ``Widget`` represents a small unit of frobnication.

## Creating widgets

Use ``Widget/init(config:)`` to create a widget...
```
