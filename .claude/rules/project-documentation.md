---
description: Project-level documentation conventions — README structure, CHANGELOG (Keep a Changelog), CONTRIBUTING, ADRs, inline-comment philosophy, link-rot discipline. Cross-platform.
globs: "README.md,CHANGELOG.md,CONTRIBUTING.md,docs/**/*.md"
---

# Project Documentation Conventions

Scoped to the repo's prose docs — `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, anything under `docs/`. For source-level doc comments (DocC, KDoc), see the platform-specific `apple-documentation-strategy.md` and `android-documentation-strategy.md`.

## README

The README's only job is to get a stranger productive in under two minutes. Every word that doesn't serve that is friction.

Required sections, in roughly this order:

1. **Title + one-line description.** A noun phrase. Someone should be able to read it and know whether to read the second line.
2. **Status badges** (CI, package version, license) — but *only if accurate*. A red CI badge tells more truth than a green stale one. Broken/stale badges are worse than missing ones.
3. **Quick Start.** Three to five lines. The fastest possible path from "I have nothing" to "I see it work." Real commands, not pseudocode.
4. **Install / Setup.** Prerequisites, install command(s), how to verify the install.
5. **Usage.** The 80% case — one realistic example. Real code, not pseudocode.
6. **Configuration.** Env vars, config files, flags. Defaults explicit. Don't make readers reverse-engineer behavior from source.
7. **Examples.** Link to longer examples in `docs/` or an `examples/` directory; don't bloat the README.
8. **Contributing.** Link to `CONTRIBUTING.md`; don't duplicate.
9. **License.** Link to `LICENSE`.

Avoid:

- **Marketing copy** before the user can run anything.
- **"Why we built this"** before "How to use this." Save the philosophy for a blog post; the README is for use.
- **Embedded GIFs over a few MB.** Use a still image plus a link to the full demo.
- **Outdated screenshots** more than a year old. Either update or remove.
- **Copy-pasted boilerplate** from other repos that doesn't apply here.

## CHANGELOG

Follow [Keep a Changelog](https://keepachangelog.com):

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Support for the `--list` flag (#42)

## [1.2.0] - 2026-04-18

### Added
- Foo bar baz, gated behind feature flag X (#123)

### Changed
- Renamed `lookupUser` → `findUser` to clarify cancellation semantics (#119)

### Deprecated
- `lookupUser` — use `findUser`; will be removed in 2.0.

### Removed
- `LegacyAuth` (deprecated in 1.0)

### Fixed
- Crash when scanning empty results (#121)

### Security
- Bumped `okhttp` to 4.12.0 to address CVE-XXXX-XXXX
```

Conventions:

- **Newest version on top.**
- **Group entries** by Added / Changed / Deprecated / Removed / Fixed / Security. Skip empty groups.
- **One entry per change**, one line, in the past tense.
- **Link to the PR or issue** — `(#123)` at the end. Lets readers dig in.
- **ISO dates** (`YYYY-MM-DD`) — unambiguous across locales.
- **`[Unreleased]`** section at top for in-progress work; promote on release.
- **Skip commit-noise.** Refactors users won't notice, internal CI tweaks, dependency-of-dependency updates — leave out.

## CONTRIBUTING

Cover only what someone needs to make a successful contribution:

- **Dev environment setup** — exact prerequisites and exact install steps.
- **How to run tests locally** — *one command*, ideally. If it's three, list all three.
- **How to run lint locally** — same.
- **Branch / PR conventions** — branch name format, PR title format, what reviewers look for.
- **Issue-tracker location** — link.
- **Code of Conduct** — link to `CODE_OF_CONDUCT.md`.

Skip:

- **Repeated PR-template content** — that goes in `.github/PULL_REQUEST_TEMPLATE.md`.
- **Project-policy churn** that changes per-PR — those belong in living docs (a wiki / `docs/`), not CONTRIBUTING.

## ADRs (Architecture Decision Records)

For non-obvious technical decisions, write an ADR under `docs/adr/####-title.md`. They make the *why* of a decision survive long after the people who made it leave.

Standard template:

```markdown
# ADR 0007: Use StateFlow over LiveData

## Status
Accepted, 2026-04-18

## Context
What problem are we solving and what constraints apply?

## Decision
What did we decide?

## Consequences
What does this mean for the codebase? What did we trade away?

## Alternatives Considered
Two or three, briefly. Note why each was rejected.
```

Conventions:

- **Numbered sequentially**, never reused. ADR 0007 is forever ADR 0007.
- **Immutable once accepted.** If the decision changes, write a new ADR (`0023`) that supersedes the old one and link forward (`Supersedes ADR 0007`).
- **Status values:** `Proposed`, `Accepted`, `Deprecated`, `Superseded by ADR ####`.
- **Write the ADR when you make the decision**, not "later." Recall is poor a year out.
- **Length:** one page is the sweet spot. If the decision needs ten pages of context, factor into an Article and link.

## Inline Comments (in source files)

Comments inside code (not doc comments) explain *why*, not *what*. The code itself is the source of truth on what.

**Bad:**

```kotlin
// Increment the counter by 1
count++
```

```swift
// Loop through the array
for item in items { ... }
```

**Good:**

```kotlin
// Order matters: counter must increment before fan-out so listeners
// observe the new value (RUMI-1283).
count++
```

```swift
// We sort by id, not name, because the renderer assumes stable ordering
// across rerenders and names can collide for unrelated users.
let sorted = items.sorted { $0.id < $1.id }
```

If you find yourself writing a "what" comment, the right move is usually to refactor:

- **Extract a function** with a name that explains the operation.
- **Replace a magic number** with a named constant.
- **Split a multi-step expression** into temporaries with descriptive names.

When you do need a comment:

- **Reference an issue, ticket, or commit hash** when you're working around something. `(#123)` / `RUMI-1283` / `(see commit abc123)` future-proofs the explanation.
- **Don't apologize.** *"This is hacky but"* doesn't help — describe what the constraint is and why this is the response.

## Link Rot

Documentation is a living artifact; links go bad faster than code. Defenses:

- **Pin versions** in install instructions: `v1.2.3`, not `latest` — readers should be able to reproduce a procedure verbatim a year later.
- **Permalink to source.** Use `/blob/<commit-sha>/path/to/file#L42` instead of `/blob/main/path/to/file#L42` — `main` shifts, the SHA doesn't.
- **Avoid blog posts as canonical sources** for installation steps. They get deleted, paywalled, or simply rot. Prefer the upstream project's docs even when a blog post is clearer.
- **Audit links on every minor release.** Five minutes of `httpie`/`curl` saves a week of "why doesn't this work?" issues.

## Common Pitfalls

- **README that's actually a CHANGELOG.** Use a real CHANGELOG.
- **CHANGELOG that's actually a Git log.** The reader wants behavior changes, not commit hashes — curate.
- **ADRs that say "we'll think about this later."** That's not a decision. Make the call when you write the doc, or don't write it.
- **Comments that lie.** A "what" comment becomes wrong when the code changes; a "why" comment ages with the constraint, not the implementation.
- **Documentation in PR descriptions** that doesn't make it back into the repo. PR description ≠ documentation.
- **Markdown that doesn't render on GitHub** — GitHub-flavored Markdown is mostly compatible with CommonMark, but custom HTML, video embeds, and mermaid blocks behave differently. Verify on the rendered page before merge.
- **Auto-generated docs as the *only* docs.** Dokka / DocC / Sphinx output is essential, but it's a reference, not an introduction. Pair it with a hand-written Quick Start.
