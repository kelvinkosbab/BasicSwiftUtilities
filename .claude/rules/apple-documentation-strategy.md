---
description: Documentation strategy for Apple — what to document (and what not), DocC discipline, deprecation, samples, articles. Complements swift-docc-pro (mechanics review).
globs: "**/*.swift"
---

# Apple Documentation Strategy

This rule answers *what* code needs documentation and *how it should be shaped*. For mechanics review (parameter tags, double-backtick symbol linking, Topics organization), invoke the `swift-docc-pro` skill — this rule covers the strategy underneath it.

## What to Document

Every `public` or `open` symbol gets a doc comment. No exceptions for "obvious" public API — if it's exported, document it.

For each documented symbol, cover:

- **Summary** — first line, one sentence, ends with a period. DocC takes this as the index entry.
- **Parameters** — `- Parameter name:` for each (or `- Parameters:` block if there are several).
- **Returns** — `- Returns:` for non-`Void` returns.
- **Throws** — `- Throws:` listing the *type* and the *cases* that can be thrown, not just "an error."
- **Complexity** — `- Complexity:` when it's non-obvious (`O(n log n)`, `O(1)` if surprising).
- **Concurrency** — note actor isolation, cancellation behavior, re-entrancy if relevant.
- **Side effects** — anything that mutates state outside the return value (writes a file, changes UserDefaults, fires an analytic event).
- **Preconditions** — what the caller must guarantee before calling (asserted via `precondition` or expressed in the type system if possible).

Internal / file-private symbols only need docs when:

- The algorithm or workaround is non-obvious.
- There's a tracked bug being worked around (link the issue).
- A concurrency invariant exists that isn't visible from the type signature.

## What NOT to Document

- **The signature.** *"Adds two numbers and returns the result"* on `func add(_ a: Int, _ b: Int) -> Int` is noise — the signature already says it.
- **Generated code.** `Codable` synthesis, `@Observable` macro expansions, `@objc` bridges. Document the things that *use* them.
- **Trivial property accessors** with no side effects. `var name: String` with a stored backing doesn't need prose.
- **Negative facts** the type system already encodes. *"Never returns nil"* on a non-optional return is redundant. *"Does not throw"* on a non-throwing function is redundant.
- **Implementation details that might change.** If the doc says "uses an internal cache," readers will rely on that and you can't change it.

## Doc Comment Mechanics

```swift
/// Returns the user with the given identifier, or `nil` if no user exists.
///
/// Hits the network on cache miss; the call is suspending and respects task
/// cancellation. Cancelling the surrounding task aborts the lookup without
/// throwing.
///
/// - Parameter id: The user's stable identifier.
/// - Returns: The matching user, or `nil` if no record exists.
/// - Throws: `NetworkError` if the network is unavailable and there's no
///   cache hit. Cancellation does not throw.
public func findUser(id: User.ID) async throws(NetworkError) -> User? { ... }
```

- **Triple-slash `///`** for doc comments. Block-style `/** ... */` is permitted but `///` is the SwiftUI / standard library convention.
- **First line is the summary.** Keep it under 100 chars; DocC truncates the index.
- **Blank line** between summary and discussion.
- **Symbol references** use double-backticks: ` ``User.ID`` `, ` ``findUser(id:)`` `. Single backticks are *just code formatting* and won't link.

## Deprecation Discipline

When deprecating, always provide direction:

```swift
@available(*, deprecated, message: "Use findUser(id:) — supports cancellation", renamed: "findUser(id:)")
public func lookupUser(_ id: String) -> User? { ... }
```

- **`message:` is mandatory** — explain *why* and *what to use instead*.
- **`renamed:`** for true renames; Xcode offers a fix-it.
- **No deprecation without a migration story.** Either deprecate-with-direction or remove the API entirely; "deprecated, will be removed someday" rots and demoralizes.
- **Escalate over releases:** introduce as `deprecated` (warning), bump to `deprecated, obsoleted: <next-version>` to make it an error, then remove. Don't let deprecated APIs live forever.

## DocC Articles vs. Doc Comments

- **Doc comment** — for one symbol; lives in source.
- **DocC Article** — for cross-symbol concepts ("Getting Started," "Working with Sessions"); lives in `Sources/<Module>/<Module>.docc/Articles/`.
- **Tutorial** — step-by-step, user-facing flows; lives in `Sources/<Module>/<Module>.docc/Tutorials/`.

If a doc comment grows past ~10 lines of prose, it probably wants to be an Article with the comment linking to it.

## Samples and Code Blocks

For non-obvious usage, embed a runnable snippet:

```swift
/// Streams a model response to the given prompt, appending tokens as they arrive.
///
/// ```swift
/// for try await chunk in session.streamResponse(to: "Hello") {
///     print(chunk, terminator: "")
/// }
/// ```
///
/// The stream completes naturally at end-of-response, or throws on cancellation.
public func streamResponse(to prompt: String) -> AsyncThrowingStream<String, Error> { ... }
```

- Always actually compilable code — DocC will error on broken samples in builds.
- For longer samples, use `@Sample` references in DocC Articles instead of inline.

## `// MARK:` vs DocC Topics

These solve different problems — use both:

- **`// MARK: -`** organizes source code in Xcode's jump bar. For source navigation by humans editing the file.
- **DocC `## Topics`** organizes the rendered API page. Group related symbols on the docs site:

  ```swift
  /// Manages a streaming chat session.
  ///
  /// ## Topics
  ///
  /// ### Sending messages
  ///
  /// - ``send(_:)``
  /// - ``cancel()``
  ///
  /// ### Observing state
  ///
  /// - ``messages``
  /// - ``isGenerating``
  public final class ChatSession { ... }
  ```

## Common Pitfalls

- **Restating the signature in prose** — *"Returns a `String` containing the user's name"* on a `var name: String`. Delete it.
- **Stale examples** — code in doc comments that compiled three refactors ago. Build-time DocC catches some of this; the rest needs review.
- **Multi-paragraph summary lines.** DocC takes only the first paragraph as the summary.
- **Single-backtick symbol references** when you meant double — ` `User` ` formats as code but doesn't *link*; ` ``User`` ` does.
- **Deprecation without migration** — `@available(*, deprecated)` with no message and no replacement.
- **HTML in DocC** — DocC supports a Markdown subset, not arbitrary HTML. Stick to backticks, asterisks, links, and lists.
- **Documenting `init(from decoder:)` / `encode(to encoder:)`** — synthesized; document the type itself, not the synthesized witness.
