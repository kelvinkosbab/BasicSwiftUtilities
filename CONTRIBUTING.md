# Contributing to BasicSwiftUtilities

Thank you for your interest in contributing to BasicSwiftUtilities!

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a new branch for your change
4. Make your changes
5. Run `swift build` and `swift test` to verify everything works
6. Open a pull request against `main`

## Development Requirements

- **Swift 6.0** or later
- **Xcode 16** or later
- macOS 14+

## Package Structure

Each module has colocated sources and tests:

```
ModuleName/
    Sources/    # Production code
    Tests/      # Test code (Swift Testing framework)
```

## Code Style

- Use Swift 6 strict concurrency — all public types should be `Sendable` where possible
- Prefer actors over `DispatchQueue`-based synchronization
- Add documentation comments (`///`) to all public declarations
- Use `@MainActor` for UI-bound code
- Follow existing naming conventions in the codebase

## Testing

- Tests use the [Swift Testing](https://developer.apple.com/documentation/testing/) framework (not XCTest)
- Use `@Suite` to group related tests
- Use `@Test` with descriptive display names
- Use `#expect` for assertions

## Adding a New Module

1. Create `NewModule/Sources/` and `NewModule/Tests/` directories
2. Add a single line to `Package.swift`:
   ```swift
   + makeTargets(name: "NewModule", dependencies: ["Core"])
   ```
3. Add a `.library` entry to the `products` array

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
