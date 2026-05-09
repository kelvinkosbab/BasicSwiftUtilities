---
description: MVVM ownership and view-model conventions for SwiftUI views
globs: "**/*.swift"
---

# SwiftUI MVVM Conventions

A SwiftUI-flavored MVVM pattern. The conventions below pin which views need view models, how view models are owned, and where state belongs. They're enforced by review, not by the compiler — a view that violates them still builds but fails the audits.

## When a view needs a view model

A SwiftUI `View` should be a thin presenter. Extract a view model when ANY of these are true:

- The view holds **business logic** beyond binding to a control's `@State` (validation, persistence, network calls, model-tier interactions).
- The view orchestrates **multi-step async work** that mutates state across the steps (e.g., validate → submit → handle response → animate).
- The view holds **5+ pieces of `@State`** that interact with each other (the cohesion smell — view should compose state, not own it).
- The view's logic needs to be **unit-testable** in isolation.
- The view is **split across extension files** (the cross-file extension visibility problem — `private` doesn't span files, so shared mutable state forces awkward `internal`-by-default declarations).

A view does NOT need a view model when:

- It only owns **UI presentation flags** (`showSheet: Bool`, `showConfirmation: Bool`, `isExpanded: Bool`).
- It's a **thin wrapper around an environment store** (e.g., a settings view reading from a shared preferences object).
- It's a **pure layout / styling component** (badges, list rows, decorative views).

## View Model Anatomy

```swift
@MainActor
@Observable
final class FeatureViewModel {

    // MARK: - State (the view binds to these)

    var inputText: String = ""
    var isLoading: Bool = false
    var pendingItem: SomeItem?

    // MARK: - Long-Lived Dependencies (captured at init)

    let service: SomeService

    // MARK: - Init

    init(service: SomeService) {
        self.service = service
    }

    // MARK: - Methods (orchestration; take short-lived deps as parameters)

    func submit(
        preferences: AppPreferences,
        reduceMotion: Bool
    ) async throws {
        // ...
    }
}
```

Required attributes:
- `@MainActor` at the **type level** (not on individual methods).
- `@Observable` (the SwiftUI macro — automatically tracks property reads).
- `final class` so SwiftUI can capture identity for state-tracking.

## Ownership: `@State` vs `@Bindable`

Two ownership patterns; pick based on lifecycle:

### `@State` owned (per-view lifecycle)

Use when the view model's lifetime should match the view's:

```swift
struct DetailView: View {
    @State var viewModel: DetailViewModel

    init(item: Item) {
        self._viewModel = State(initialValue: DetailViewModel(item: item))
    }
}
```

Most form sheets, detail screens, and per-item editors fit this pattern.

### `@Bindable` injected (shared across siblings)

Use when multiple views need the same instance — typically because the underlying resource has external constraints (delegate slots, persistent connections, single source of truth):

```swift
struct ListView: View {
    @Bindable var viewModel: SharedListViewModel
}
```

Common reasons to share a single instance:
- The underlying service exposes only one `weak var delegate` slot — two view models would race for it.
- A long-running network or scan operation must not be started twice.
- Multiple tabs need to read/mutate the same in-memory collection.

If you find yourself reaching for an injected view model, ask: "would two instances cause incorrect behavior?" If yes, share. If no, prefer per-view ownership.

## Dependency Plumbing

View models capture **long-lived dependencies** at init time. They take **short-lived environment values** as method parameters:

```swift
@MainActor @Observable final class FeatureViewModel {

    // Long-lived: captured at init, used by every method.
    let service: SomeService

    init(service: SomeService) {
        self.service = service
    }

    // Short-lived: passed by the View at the call site.
    func submit(
        preferences: AppPreferences,    // @Environment value
        reduceMotion: Bool              // @Environment value
    ) async {
        // ...
    }
}
```

Why split:

- View models stay **free of `@Environment` reads** — those are SwiftUI types tied to a specific view body evaluation, and pulling them into a class breaks testability.
- Tests inject any value they want into method parameters. `view.environment(...)` plumbing isn't needed for unit tests.
- The view is the single owner of `@Environment` reads, resolved once per body and forwarded to the view model.

## What Stays on the View

These belong on the View struct, not the view model:

- **`@FocusState`** — binds to the view's focus chain, can't traverse a class boundary.
- **`@Environment`** reads — view-body-evaluation-scoped.
- **Pure UI flags** with no business logic (the View can keep simple `@State` for "is this section expanded right now").
- **`@State viewModel: SomeViewModel`** — the one piece of view-owned state.
- **SwiftUI-specific bindings** like `Binding<Bool>` to bridge VM optionals to `.confirmationDialog(isPresented:)` — these synthesize a SwiftUI type from VM state, so they live where the SwiftUI type is consumed.

## Splitting Large View Models

When a view model exceeds ~300 lines or the SwiftLint `type_body_length` warning, split it via Swift extensions in companion files mirroring the View's split:

```
FeatureViewModel.swift          // class declaration, state, init, lifecycle
FeatureViewModel+Send.swift     // submit pipeline, validation
FeatureViewModel+Scroll.swift   // scroll/animation state machine
FeatureViewModel+Intents.swift  // intent dispatch
```

Methods in the extension files default to `internal` access (which works for cross-file calls within the module). `private` only works within a single file — use `private` for helpers that genuinely don't escape the file.

## Forms

Forms (TextField + validation + submit) particularly benefit from view models:

```swift
@MainActor @Observable final class CreateFooViewModel {

    var name: String = ""
    var nameError: String?
    var details: String = ""
    var detailsError: String?

    var isFormValid: Bool {
        !name.trimmed.isEmpty && !details.trimmed.isEmpty
    }

    func validate() -> ValidatedInputs? {
        // Returns nil after surfacing the first error; otherwise the struct.
    }

    func submit() async throws {
        // Calls into the persistence / network layer.
    }
}
```

Multi-init pre-fill paths (e.g. "create-from-scratch" + "edit-existing" + "prefilled-from-elsewhere") collapse to static factory methods on the view model:

```swift
extension CreateFooViewModel {
    static func empty() -> CreateFooViewModel { ... }
    static func editing(_ existing: Foo) -> CreateFooViewModel { ... }
    static func prefilled(from intent: SomeIntent) -> CreateFooViewModel { ... }
}
```

This pattern also lets the View's three corresponding inits collapse into thin wrappers that just pick the right factory — keeping init signatures focused on what the *caller* provides rather than how the VM should be configured.

## Common Pitfalls

- **Don't put `@Environment` reads on the view model.** They only work in views.
- **Don't put `Binding<T>` on the view model.** It's a SwiftUI type tied to a view body. Bindings synthesize on the view side: `@Bindable var bindable = viewModel; TextField(text: $bindable.field)`.
- **Don't put validation logic in the view body.** If the view has a `private func validateForm()`, that's a view model waiting to be extracted.
- **Don't capture `@Environment` values in view-model closures via `self.environmentValue`.** Pass them in.
- **Don't make the view model hold a reference back to the view.** The view re-renders; the view model persists. The relationship is one-way.
- **Don't hold long-lived `Task` references in the view model without a cancellation strategy.** Either use structured concurrency tied to a method's lifetime, or hold the `Task` and cancel it explicitly in a `deinit`-equivalent path.

## Patterns to Follow

```swift
// View
struct FeatureView: View {

    @Environment(\.appPreferences) private var preferences
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isInputFocused: Bool
    @State private var viewModel: FeatureViewModel

    init(service: SomeService) {
        self._viewModel = State(initialValue: FeatureViewModel(service: service))
    }

    var body: some View {
        @Bindable var bindable = viewModel
        Form {
            TextField("Name", text: $bindable.name)
                .focused($isInputFocused)

            Button("Submit") {
                Task {
                    await viewModel.submit(
                        preferences: preferences,
                        reduceMotion: reduceMotion
                    )
                }
            }
            .disabled(!viewModel.isFormValid)
        }
    }
}
```
