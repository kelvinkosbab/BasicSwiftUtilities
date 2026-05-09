---
description: Enforce SwiftUI accessibility best practices for VoiceOver, Dynamic Type, and Reduce Motion
globs: "**/*.swift"
---

# Accessibility Best Practices

All views must be fully accessible. VoiceOver, Dynamic Type, and Reduce Motion support are required, not optional.

## VoiceOver Labels & Hints

- Every interactive element (Button, Toggle, Picker, NavigationLink) must have an `.accessibilityLabel` if its purpose isn't clear from its visible text.
- Add `.accessibilityHint` when the action isn't obvious from the label alone (e.g., destructive actions, toggles that affect other UI, long-press gestures).
- Compound views (HStack/VStack with icon + text) must use `.accessibilityElement(children: .combine)` so VoiceOver reads them as a single element.
- Decorative icons must use `.accessibilityHidden(true)`.

## Localization

- **Never hardcode English strings** in accessibility attributes. All `.accessibilityLabel`, `.accessibilityHint`, and `.accessibilityActions` text must use `Strings.Accessibility.*` from `BonjourLocalization`.
- Use `String(localized:)` for `LocalizedStringResource` values and format functions like `Strings.Accessibility.copyField(name)` for dynamic content.

## Section Headers

- All `Section` header views must include `.accessibilityAddTraits(.isHeader)` so VoiceOver users can navigate by heading.

## Accessibility Actions

- Rows with context menus must also provide `.accessibilityActions` with the same options, since context menus aren't discoverable via VoiceOver's default rotor.
- Use localized action labels from `Strings.Accessibility.*` (e.g., `.copyRecord`, `.editRecord`, `.deleteRecord`).

## Accessibility Identifiers

- Add `.accessibilityIdentifier` to key interactive elements (toolbar buttons, form submit buttons) for UI testing.

## Dynamic Type

- Use semantic fonts (`.font(.headline)`, `.font(.body)`) — never `.font(.system(size:))`.
- Compound layouts (icon + title + detail) should switch from `HStack` to `VStack` at larger Dynamic Type sizes using `@Environment(\.dynamicTypeSize)`.
- Cap Dynamic Type on compact UI elements with `.dynamicTypeSize(...DynamicTypeSize.xxxLarge)` or `.accessibility1` where layout would break.

## Reduce Motion

- Always check `@Environment(\.accessibilityReduceMotion)` before animating.
- Use `withAnimation(reduceMotion ? nil : .default)` instead of bare `withAnimation`.
- This applies to show/hide transitions, state changes, and any animated UI updates.

## Pickers with Hidden Labels

- When using `.labelsHidden()` on a `Picker` inside `LabeledContent`, add `.accessibilityLabel` directly to the `Picker` to restore VoiceOver context that `.labelsHidden()` strips.

## Disabled State Hints

- Buttons with `.disabled` conditions should provide `.accessibilityHint` explaining why the button is disabled (e.g., "Complete all required fields to enable this button").

## Streaming AI Text (Foundation Models / chat UIs)

- While a response is generating, set `.accessibilityLabel` to a localized "thinking" string (e.g., `Strings.Accessibility.chatAssistantThinking`). Once the stream completes, swap to the final content.
- **Do not announce every streamed token** — VoiceOver will stutter and interrupt itself. Let the final label update carry the message.
- Decorative "typing" indicators (animated dots, shimmering placeholders) must use `.accessibilityHidden(true)`; the label on the parent element already communicates state.
- Error banners for AI failures must be focusable and announced — use `.accessibilityLabel` with the localized error and `.accessibilityAddTraits(.isStaticText)`.
- Respect `@Environment(\.accessibilityReduceMotion)` for typing-indicator animations — disable the shimmer when motion is reduced.

## Patterns to Follow

```swift
// Compound element
HStack {
    Image(systemName: "wifi").accessibilityHidden(true)
    VStack { Text(title); Text(detail) }
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(title), \(detail)")

// Section header
Section {
    // content
} header: {
    Text(Strings.Sections.title)
        .accessibilityAddTraits(.isHeader)
}

// Animated toggle respecting Reduce Motion
Toggle("Label", isOn: $binding)
    .onChange(of: binding) {
        withAnimation(reduceMotion ? nil : .default) { ... }
    }

// Picker with hidden label
Picker("Label", selection: $value) { ... }
    .labelsHidden()
    .accessibilityLabel("Label")

// Context menu with matching accessibility actions
.contextMenu {
    Button { copy() } label: { Label("Copy", systemImage: "doc.on.doc") }
}
.accessibilityActions {
    Button(String(localized: Strings.Accessibility.copyRecord)) { copy() }
}
```
