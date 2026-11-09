---
description: Test strategy and coverage discipline for Apple platforms — what to test, naming, determinism, mocking, Swift Testing vs XCTest split, and CI coverage gates
globs: "**/*.swift"
paths:
  - "**/*.swift"
must:
  - "New tests use Swift Testing, including UI tests on Xcode 27; keep XCTest only for measure performance tests."
  - "Inject clocks, UUIDs, randomness, and network; no `Date()`, `Thread.sleep`, or live network in tested code."
  - "Name tests by behavior and test through public API."
  - "UI tests find elements by `accessibilityIdentifier`, never localized text."
---

# Apple Testing Strategy & Coverage

*What* to test and *how much*. This is the checklist; the examples, the XCTest migration notes, and the reasons are in [`test-strategy.md`](../skills/swift-testing-pro/references/test-strategy.md). For *how* to write a Swift Test, use `swift-testing-pro`.

## What to test

- **Mostly unit tests** (pure logic, view models, services with mocked dependencies, each under a second), fewer integration tests (an in-memory Core Data stack, `URLProtocol` stubs), fewest UI tests.
- **Test** every branch and edge case of pure functions, the public API of stateful types, every state transition including errors, cancellation / retry / timeout, and a regression test for each fixed bug.
- **Don't test** private details, third-party SDKs, generated code (`@Observable`, `Codable`, macros, previews), DI wiring, pixel layout, or a value type's memberwise `init`.

## Naming

- `<TypeName>Tests.swift`; `@Suite("Type Name")`; name the behavior, not the method (`loginRejectsExpiredToken()`); `@Test("…")` for readable failures; `@Test(arguments:)` instead of near-identical copies.

## Determinism

- **Inject clocks, dates, UUIDs, randomness, the file system, and the network.** No `Date()`, `UUID()`, or `Date.now` in code under test; take `now: () -> Date` or `any Clock`.
- **No `Thread.sleep` / `Task.sleep` in tests, no live network, no shared mutable state** (statics, `UserDefaults.standard`, fixed on-disk paths). Swift Testing runs in parallel.
- **`@MainActor` on the suite or test** when the type under test is main-actor isolated.

## Mocking

- **Mock at protocol boundaries you own**; build value types with fixtures (`User.fixture(…)`), never mocks.
- **`#require` to unwrap**, not `try!` or `XCTUnwrap`. Spies record inputs for side-effect assertions.

## Frameworks

- **Swift Testing for new unit, integration, and (Xcode 27) UI tests**; XCTest only for `measure {}` performance tests. One framework per test target.
- **Flakes**: reproduce with `swift test --repeat-until fail --maximum-repetitions <n>`, then fix the determinism bug. Never ship `--repeat-until pass`.

## UI tests

- Find elements by `accessibilityIdentifier`, never localized text. Page objects for multi-screen flows. No `sleep()`; wait with `waitForExistence(timeout:)`. Set app state with launch arguments.

## Coverage

- **Track line coverage in CI** (`xcrun xccov`) and set a floor the team will keep (70–80% is typical). Exclude generated code, DI wiring, data-only types, `#if DEBUG` preview helpers, and `@main`.
- **Don't game it**: a covered line with no real assertion is worse than an uncovered one. Delete `#expect(true)` and "doesn't crash" tests.
