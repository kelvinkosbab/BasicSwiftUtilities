---
description: MVVM ownership and view-model conventions for SwiftUI views
globs: "**/*.swift"
paths:
  - "**/*.swift"
must:
  - "View models are `@MainActor @Observable final class`, with dependencies passed at init."
  - "View models never hold `@Environment` or `Binding`; pass environment values into methods."
  - "Own with `@State` per view; share with `@Bindable` only when two instances would race over one resource."
  - "Extract a view model when the view has business logic, multi-step async, or needs unit tests."
---

# SwiftUI MVVM Conventions

Which views need a view model, how it's owned, and where state lives. This is the checklist; the examples, the form and splitting patterns, and the reasons are in [`mvvm-conventions.md`](../skills/swiftui-pro/references/mvvm-conventions.md). Review with `swiftui-pro`.

## When to extract a view model

- **Extract one** when the view has business logic (validation, persistence, network), multi-step async work, five or more interacting `@State` values, logic that needs unit tests, or state shared across extension files.
- **Don't** for views that only hold UI flags (`showSheet`, `isExpanded`), thin wrappers over an environment store, or pure layout and styling components.

## Anatomy

- **`@MainActor @Observable final class`**, with `@MainActor` on the type, not on methods.
- **Long-lived dependencies are captured at `init`**; short-lived environment values (preferences, `reduceMotion`) are **method parameters** passed by the view.
- **No `@Environment`, `Binding`, or reference back to the view** inside a view model. Bindings are made on the view: `@Bindable var bindable = viewModel`.
- **Long-lived `Task`s have a cancellation path**; prefer structured concurrency tied to a method.

## Ownership

- **`@State var viewModel`** when its life matches the view's (forms, detail screens, editors), created in `init` with `State(initialValue:)`.
- **`@Bindable` injected** only when two instances would be wrong: one delegate slot, one long-running scan or connection, or a collection several tabs mutate.

## What stays on the view

- `@FocusState`, `@Environment` reads, pure UI flags, and SwiftUI-only bridges such as a `Binding<Bool>` built from view-model state for `.confirmationDialog(isPresented:)`.

## Size and forms

- **Over about 300 lines, split by extension** into `FeatureViewModel+Send.swift`, `+Scroll.swift`, …, mirroring the view's split. `private` only for helpers that stay in one file.
- **Forms**: fields, per-field errors, `isFormValid`, `validate()`, and `submit()` live on the view model. Several init paths (empty, editing, prefilled) become static factories (`.empty()`, `.editing(_:)`, `.prefilled(from:)`).
- **No validation in the view body.** A `private func validateForm()` on a view is a view model waiting to be extracted.
