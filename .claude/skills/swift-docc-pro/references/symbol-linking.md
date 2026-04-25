# Symbol Linking

## Single vs double backticks

- Single backtick `` `Widget` `` — renders as inline code, no link.
- Double backtick ```` ``Widget`` ```` — renders as a clickable link to the symbol's page.

**Always prefer double backticks for type references** so DocC creates navigation:

```swift
/// See ``RetryStrategy`` for available strategies.
```

## Linking to members

Use the path syntax `Type/member`:

```swift
/// Use ``Widget/configure(with:)`` to apply settings.
/// Read ``Widget/state-swift.property`` to inspect current state.
```

For overloaded methods, include the parameter labels:

```swift
/// See ``Widget/init(name:)`` and ``Widget/init(name:config:)``.
```

## Disambiguation suffixes

When a symbol's name collides with a Swift keyword or another symbol, add a disambiguation suffix:

| Suffix | Meaning |
|--------|---------|
| `-swift.property` | Property |
| `-swift.method` | Method |
| `-swift.init` | Initializer |
| `-swift.enum.case` | Enum case |
| `-swift.type.method` | Static method |

```swift
/// See ``Widget/state-swift.property`` (the property, not the type).
```

## Cross-module linking

Reference symbols in other modules with the module prefix:

```swift
/// Conforms to ``Foundation/Codable``.
/// Uses ``Core/Loggable`` for logging.
```

## Linking to top-level symbols

For a top-level type or function, the bare name works:

```swift
/// See ``asyncRetry(max:strategy:_:)``.
```

For a top-level function with no overloads, you can omit the parameter labels:

```swift
/// See ``asyncRetry(_:)``.
```

## When linking fails silently

DocC won't error if a symbol link doesn't resolve — the link just renders as plain code. Verify links by:

1. Building docs with `swift package generate-documentation` (or via Xcode's "Build Documentation").
2. Checking the rendered HTML for unresolved links (they appear as code, not links).

## Linking to articles and tutorials

Use `<doc:>` syntax:

```swift
/// For an overview, see <doc:UsingWidgets>.
```

The article filename (without `.md`) goes inside `<doc:>`.

## External documentation

For external links, use standard markdown:

```swift
/// For more information see [Apple's documentation for `os.Logger`](https://developer.apple.com/documentation/os/logger).
```

Always link to Apple's docs rather than third-party tutorials when possible — Apple's docs stay current.
