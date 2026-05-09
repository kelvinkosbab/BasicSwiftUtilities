---
description: Test strategy and coverage discipline for Apple platforms — what to test, naming, determinism, mocking, Swift Testing vs XCTest split, and CI coverage gates
globs: "**/*.swift"
---

# Apple Testing Strategy & Coverage

This rule answers *what* to test and *how much*. For *how to write a Swift Test* (the modern API, parameterized tests, `#expect` vs `#require`), invoke the `swift-testing-pro` skill.

## Test Pyramid

- **Unit tests** — the bulk of the suite. Pure logic, view models, services with mocked dependencies. Fast (each <1s), no I/O, no UI.
- **Integration tests** — fewer. Verify a slice of real wiring (e.g., a real Core Data stack with `NSInMemoryStoreType`, a real `URLSession` with `URLProtocol` stubs).
- **UI tests** — fewest. End-to-end flows via XCUITest. Slow, flaky if not careful, run on schedule or pre-merge — not on every save.

## What to Test

- **Pure functions** — every meaningful branch, every edge case (empty, nil, max, malformed input).
- **Public API of stateful types** — view models, services, persistence wrappers. Test through the public API, not through `@testable import` for the sake of reaching internals.
- **State transitions** — for a state machine or async pipeline, every transition path including error paths.
- **Concurrency edges** — cancellation, retry, timeout. Use injected clocks and `Task.cancel()` to drive these deterministically.
- **Boundary regressions** — once a bug is fixed, write a test that would have caught it.

## What NOT to Test

- **Private implementation details** — they change. Test through the public surface; if a private detail needs verification, the surface is missing a method.
- **Third-party SDKs** — trust them. Mock at *your* boundary (a protocol you own), not theirs.
- **Generated code** — `@Observable`, `Codable` synthesis, `@objc` bridges, macro expansions, SwiftUI previews. Test the things that *use* them.
- **DI container wiring** — test the things the container hands out, not the wiring.
- **SwiftUI view layout pixel-by-pixel** — snapshot tests have a place but are noisy and not required for every view.
- **`init` of a value type that just stores its arguments** — there's nothing to verify.

## Naming Conventions

- File: `<TypeName>Tests.swift` next to source it tests, or under a parallel `Tests/` folder.
- Suite (Swift Testing): `@Suite("<Type Name>") struct <TypeName>Tests` — backticked descriptive name lets you read the failure message.
- Method: name the *behavior*, not the method-under-test. `loginRejectsExpiredToken()` beats `testValidate()`.
- Use `@Test("description with spaces")` for richer failure output.
- Group related cases with parameterized tests (`@Test(arguments: [...])`) instead of N near-identical methods.

## Determinism

Tests that pass intermittently are worse than no tests — they teach the team to ignore failures.

- **Inject anything that observes the outside world**: clocks, dates, UUIDs, randomness, file system, network. Production code accepts them as parameters; tests substitute fixed values.
- **No raw `Date()` / `UUID()` / `Date.now` in code under test.** Take a `now: () -> Date` or `clock: any Clock` parameter instead.
- **No `Thread.sleep` or `Task.sleep` in tests.** Use a mock clock (e.g., `ContinuousClock` substitute) or drive timing via cancellation.
- **No live network.** Mock at a protocol boundary you own; never hit a real endpoint, even a "test" one.
- **No shared mutable state across tests.** Swift Testing runs in parallel by default — global statics, `UserDefaults.standard`, on-disk fixtures will collide. Inject ephemeral instances.
- **Set `@MainActor` on the suite or test** when the type under test is `@MainActor`-isolated (view models, Core Data via `viewContext`).

## Mocking

- **Mock at protocol boundaries.** Production code depends on protocols (`AuthAPIProtocol`); tests substitute mocks.
- **Don't mock value types.** Construct them with test data — value-type fixtures via static factories: `User.fixture(name: "Test")`.
- **Use `#require()` for unwrapping**, not `try!` chains. `#require` short-circuits the test with a clean failure message instead of crashing.
- **Spy / record patterns** for verifying side effects: a mock that captures inputs into an array, asserted against later.

## Swift Testing vs XCTest

- **Default to Swift Testing** for new unit and integration tests. `@Test`, `@Suite`, `#expect`, `#require` — modern API, parallel execution, parameterized tests built in.
- **Keep XCTest for**:
  - **UI tests** (XCUITest) — Swift Testing does not support UI tests.
  - **Performance tests** (`measure { }`) — XCTest is the only option.
- **Don't mix in the same target.** They can coexist in a project, but a single test target should be one or the other for clarity.

## UI Testing (XCUITest)

- **Locate by `.accessibilityIdentifier(...)`,** never by visible localized text — the latter breaks every time you ship a translation.
- **Page Object Model** for non-trivial flows: each screen is a struct exposing semantic actions (`loginScreen.signIn()`), tests compose those.
- **No `sleep()` calls** — use `XCTestCase.expectation(for:evaluatedWith:handler:)` with a predicate, or `XCTestCase.wait(for:timeout:)`.
- **Set up app state via launch arguments**, not by driving the UI through five screens to get to the one you care about.

## Coverage

Coverage is a *hint about what you didn't test*, not a goal in itself.

- **Track line coverage in CI** — `xcrun xccov` against the `.xcresult` bundle, or tools like Slather or Codecov.
- **Set a project gate** as a *policy decision* — typical projects land at 70–80% line coverage as a CI floor. Pick what your team will actually maintain; a high floor that everyone routes around is worse than a realistic one that holds.
- **Exclude from coverage** (these inflate or deflate the number for no signal):
  - Generated code: `*.generated.swift`, macro expansions, Codable conformances on data-only types.
  - DI container wiring (the `@Environment` keys file, factory closures with no logic).
  - Pure-data model types with no behavior.
  - Preview helpers behind `#if DEBUG`.
  - `@main` entry points and `App`-level wiring.
- **Don't game it.** A line covered by a test that doesn't actually verify behavior is *worse* than an uncovered line — it gives false confidence. Review test bodies, not just the coverage delta.

## Patterns to Follow

```swift
// Production code — inject dependencies for determinism
@MainActor @Observable
final class LoginViewModel {
    private let api: any AuthAPIProtocol
    private let now: () -> Date

    init(api: any AuthAPIProtocol, now: @escaping () -> Date = Date.init) {
        self.api = api
        self.now = now
    }
}

// Test — Swift Testing, @MainActor, deterministic clock, mock at protocol boundary
@Suite("LoginViewModel")
@MainActor
struct LoginViewModelTests {

    @Test("rejects expired tokens")
    func rejectsExpiredTokens() async throws {
        let mockAPI = MockAuthAPI()
        let viewModel = LoginViewModel(
            api: mockAPI,
            now: { Date(timeIntervalSince1970: 1_000_000) }
        )

        let result = await viewModel.validate(token: .expiredFixture)

        #expect(result == .failure(.expired))
        #expect(mockAPI.recordedCalls.isEmpty, "expired tokens shouldn't hit the API")
    }

    @Test("accepts valid tokens", arguments: Token.validFixtures)
    func acceptsValidTokens(_ token: Token) async throws {
        let mockAPI = MockAuthAPI(stubbedResult: .success(.fixture()))
        let viewModel = LoginViewModel(api: mockAPI, now: { .now })

        let result = try await #require(await viewModel.validate(token: token).user)

        #expect(result.id == User.fixture().id)
    }
}

// Test fixture — static factory, not a mock
extension User {
    static func fixture(id: String = "test-id", name: String = "Test User") -> User {
        User(id: id, name: name)
    }
}
```

## Common Pitfalls

- **Order-dependent tests** — make tests stand alone; never rely on a previous test's side effects. Swift Testing's parallel default exposes these instantly.
- **Time-dependent tests** — inject a clock, never `Date()`.
- **`UserDefaults.standard` in tests** — leaks state across runs. Use a separate suite name or `InMemory` defaults.
- **Tests for the sake of coverage** — if the only assertion is `#expect(true)` or "no crash," delete it.
- **One giant `@Test` with twelve assertions** — split into focused tests. When one fails, you should know exactly which behavior broke.
- **`XCTUnwrap` everywhere in Swift Testing code** — use `#require` instead.
- **Snapshot tests as the *only* test for a view model** — snapshots catch render diffs, not logic bugs.
- **Force-unwrap `Bundle.module` resources** — fail the test cleanly with `#require(Bundle.module.url(forResource: ...))` instead of `!`.
