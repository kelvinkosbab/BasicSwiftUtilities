# Topics: Organizing Symbol Pages

## Why use `## Topics`?

By default, DocC lists a type's members alphabetically. For types with many members, this hurts discoverability — initializers mix with helpers mix with internal-feeling utilities.

A `## Topics` section in the type's documentation lets you group related symbols.

## Adding Topics in inline doc comments

Add `## Topics` to the type's main doc comment:

```swift
/// A widget that frobnicates the input.
///
/// Use ``Widget`` to apply transformations to data streams. Configure with
/// ``Configuration`` to control behavior.
///
/// ## Topics
///
/// ### Creating Widgets
///
/// - ``init(name:)``
/// - ``init(name:config:)``
///
/// ### Configuration
///
/// - ``Configuration``
/// - ``configure(with:)``
///
/// ### Frobnication
///
/// - ``frobnicate(_:)``
/// - ``frobnicateAsync(_:)``
public struct Widget { }
```

## Adding Topics in a `.docc` catalog

For richer organization, create an extension file in your `.docc` catalog:

```
MyModule.docc/
    Widget.md
```

```markdown
# ``Widget``

A widget that frobnicates the input.

## Topics

### Creating Widgets

- ``Widget/init(name:)``
- ``Widget/init(name:config:)``

### Configuration

- ``Widget/Configuration``
- ``Widget/configure(with:)``

### Frobnication

- ``Widget/frobnicate(_:)``
- ``Widget/frobnicateAsync(_:)``
```

## Common topic groupings

For a type, consider grouping by:

- **Creating** — initializers and factory methods
- **Configuration** — settings, options, customization
- **Operations** — main verbs the type supports
- **State Inspection** — read-only properties
- **Conformances** — protocol conformances worth highlighting
- **Errors** — associated error types

For a module's top-level page:

- **Essentials** — types most users start with
- **Subsystem A** / **Subsystem B** — major feature areas
- **Errors** — error types
- **Articles** — link to overview articles with `<doc:ArticleName>`

## Module-level Topics

The module-level `MyModule.md` file in the `.docc` catalog is the package's home page:

```markdown
# ``MyModule``

A modern toast notification system for SwiftUI apps.

## Overview

`MyModule` provides a queue-based toast system that integrates with the
SwiftUI environment...

## Topics

### Essentials

- ``ToastApi``
- ``ToastOptions``

### Customization

- ``ToastableContainer``
- <doc:CustomizingToasts>

### Articles

- <doc:GettingStarted>
- <doc:Migrating>
```

## When NOT to use Topics

For types with fewer than ~5 public members, alphabetical order is fine. Don't over-organize. The goal is discoverability, not bureaucracy.
