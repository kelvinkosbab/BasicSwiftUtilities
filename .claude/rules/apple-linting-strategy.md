---
description: SwiftLint + formatter (swift-format / SwiftFormat) strategy for Apple projects — config structure, opt-in and analyzer rules, suppression hygiene, where it runs, incremental adoption, version pinning
globs: "**/{*.swift,.swiftlint.yml,.swiftlint.yaml,.swift-format,.swiftformat}"
---

# Apple Linting Strategy

Two different jobs, two different tools — don't conflate them:

- **A formatter** rewrites whitespace and layout deterministically (indentation, wrapping, spacing). Output is mechanical; you never argue with it.
- **A linter** (SwiftLint) flags style *and* correctness smells (force-unwraps, long bodies, redundant code) — most of which a formatter can't touch.

Pick **one** owner for formatting and let the linter own everything else. Running two tools that both reformat (e.g., SwiftLint's formatting rules *and* SwiftFormat) means they fight and CI flaps. This rule covers SwiftLint as the primary linter and names the formatter options; for the SPM build-tool-plugin wiring, see [`apple-spm-package-conventions.md`](./apple-spm-package-conventions.md).

## Tool Choice

- **SwiftLint** ([realm/SwiftLint](https://github.com/realm/SwiftLint)) — the de-facto linter. Use it. It also has autocorrect for a subset of rules.
- **Formatter — pick one:**
  - **[SwiftFormat](https://github.com/nicklockwood/SwiftFormat)** (nicklockwood) — the most-used formatter; aggressive, highly configurable via `.swiftformat`.
  - **[swift-format](https://github.com/swiftlang/swift-format)** (Apple official) — ships with the toolchain on recent Swift; configured via `.swift-format` JSON. More conservative, fewer knobs.
  - These are **different tools** with similar names. Choose one; do not run both.
- **Don't** enable SwiftLint's opinionated formatting rules (e.g., `vertical_whitespace`, `trailing_comma`) *and* a separate formatter that disagrees. Let the formatter own layout; disable the overlapping SwiftLint rules.

## `.swiftlint.yml` Structure

```yaml
# Paths to lint (default: everything under the invocation dir).
included:
  - Sources
  - Tests
# Paths to skip — generated code, vendored deps, build output.
excluded:
  - .build
  - "**/*.generated.swift"
  - "**/Generated"
  - Pods
  - DerivedData

# Rules ON by default that you want OFF (justify each — see "Disabling" below).
disabled_rules:
  - todo                      # noisy if the team tracks TODOs in an issue tracker

# Rules OFF by default that are worth turning ON (the high-value set).
opt_in_rules:
  - force_unwrapping          # flags `!` — the single highest-value opt-in
  - empty_count               # `.isEmpty` over `.count == 0`
  - first_where               # `.first(where:)` over `.filter {}.first`
  - contains_over_filter_count
  - explicit_init
  - redundant_nil_coalescing
  - closure_spacing
  - sorted_imports
  - unused_import             # analyzer rule — see below
  - unused_declaration        # analyzer rule — see below
  - private_outlet
  - overridden_super_call

# Analyzer rules (require `swiftlint analyze` + compiler args — slower, CI-only).
analyzer_rules:
  - unused_import
  - unused_declaration

# Per-rule configuration.
line_length:
  warning: 120
  error: 200
  ignores_comments: true
  ignores_urls: true
type_body_length:
  warning: 300
  error: 400
identifier_name:
  min_length: 2               # allow `id`, `x`, `to`
  excluded: [id, x, y, z, to, of]
```

- **`opt_in_rules` is where the value is.** SwiftLint ships ~200 rules but many of the best ones are OFF by default. `force_unwrapping` alone catches a major crash class.
- **`included` / `excluded`** — always exclude generated code and `.build`. Linting generated files produces noise you can't fix.
- **Per-rule config beats blanket disabling** — tune `line_length`/`identifier_name` thresholds rather than turning the rule off entirely.

## Analyzer Rules

A handful of rules (`unused_import`, `unused_declaration`, `capture_variable`, `typesafe_array_init`) need the compiler's view of the code, so they run via `swiftlint analyze`, not plain `swiftlint`:

```bash
# Generate a compiler log, then analyze against it (slower — CI, not every save).
swiftlint analyze --compiler-log-path build.log
```

- These are **high-value but slow** — run them in CI, not in the incremental-build path.
- They need a fresh compiler log; stale logs give wrong results.

## Suppression Hygiene

When a rule genuinely shouldn't apply, suppress at the **smallest scope** and **say why**:

```swift
// Prefer the single-line form — auto-scoped, can't leak.
// swiftlint:disable:next force_unwrapping
let url = URL(string: "https://example.com")!   // compile-time constant, can't fail

// Region form — MUST be re-enabled, else it leaks to EOF.
// swiftlint:disable force_cast
…
// swiftlint:enable force_cast
```

- **`:next` / `:this` / `:previous`** scope to one line — prefer these.
- **`disable` without `enable`** leaks to end-of-file. If you use the region form, always pair it.
- **Never blanket-disable a whole file** by putting `// swiftlint:disable all` at the top. If a file needs that, it belongs in `excluded:`.
- **Every suppression gets a trailing comment** explaining the exception. An unexplained `disable` is a future bug.

## Triage — What To Do When a Rule Fires

A finding is a question, not a verdict — but the answer is *usually* "fix it." When it isn't, there's an order of preference. Reaching past the top of this list to silence a finding is how a config rots into noise everyone ignores.

**Per-finding decision order (prefer earlier):**

1. **Fix the code.** The default. Most findings are real; the linter is right more often than your gut says. This is the only response that improves the codebase.
2. **Tune the rule** — when the rule is *valuable* but its *threshold* is wrong for this project (line length, `type_body_length`, `cyclomatic_complexity`, `identifier_name` length). Adjust the config **once, globally**, in `.swiftlint.yml`. One config edit beats N call-site suppressions.
3. **Suppress at the call site** — `// swiftlint:disable:next <rule>` with a reason — when *this one instance* is a justified exception but the rule is right in general (a compile-time-constant force-unwrap, a deliberately long generated literal).
4. **Disable the rule project-wide** — only when the rule is *wrong for the whole codebase* (e.g., it fights a framework convention). Rare. Put it in `disabled_rules:` with a comment saying why.

Never invert this. Jumping to step 4 to clear a single finding throws away the rule's value everywhere else.

**Prioritizing a backlog** (turning SwiftLint on existing code floods you — work it in tiers, not all at once):

- **Tier 1 — correctness.** `force_unwrapping`, `force_cast`, `force_try` — real crash classes. Fix now; set these to `error` severity so they block CI.
- **Tier 2 — bug-prone smells.** Complexity, large types, `unused_declaration`. Fix where cheap; defer the rest behind `excluded:` until you reach them.
- **Tier 3 — style.** Spacing, ordering, idioms. The formatter + `--fix` (`swiftlint --fix`) auto-corrects most. Don't hand-fix what autocorrect handles.

**Severity as a gate:** correctness rules → `error` (blocks CI). Style rules → `warning` while adopting, then promote to `error` once you're clean so they can't regress. SwiftLint has no first-class baseline file — the backlog tool is `excluded:` (carve out untidy dirs) plus **incremental `opt_in_rules`** (enable a batch, fix it, enable the next), not a giant `disabled_rules` list.

**Anti-patterns:**

- **Blanket-disabling a rule to make CI green.** That's deleting the rule, dressed up. Fix, tune, or scope-suppress instead.
- **Suppressing without a reason comment** — the next reader can't tell a justified exception from laziness.
- **Treating all findings as equal** — a `force_unwrapping` and a missing blank line are not the same priority. Triage by tier.
- **Adding to `disabled_rules:` as a backlog shortcut** — that debt never gets paid. Prefer per-rule thresholds and `excluded:` paths you'll revisit.

## Where It Runs

| Location | Purpose | Notes |
|----------|---------|-------|
| **SPM build-tool plugin** | Lints on every `swift build` | See `apple-spm-package-conventions.md`. Per-target; can slow incremental builds. |
| **Xcode Run Script Build Phase** | Lints in Xcode | Common for app targets. Guard with `if command -v swiftlint`. Don't fail local builds on warnings. |
| **Pre-commit hook** | Fast local fail | `swiftlint --quiet` on staged files. Optional; CI is the real gate. |
| **CI** | The authoritative gate | `swiftlint --strict` (warnings → errors). This is non-negotiable. |

- **CI uses `--strict`** so warnings can't accumulate. Local dev tolerates warnings (autocorrect-on-save handles most).
- **Don't run the analyzer in the build phase** — it's too slow. CI only.
- **Pin the SwiftLint version** (SPM plugin version, Homebrew formula, or Mint). Rule sets change between releases; an unpinned `brew upgrade` can turn a green CI red with no code change.

## Incremental Adoption on a Legacy Codebase

Turning SwiftLint on a large untidy codebase floods you with thousands of warnings. Adopt gradually:

1. Start with `excluded:` for generated/vendored code.
2. Enable the **default rules** first; get to zero warnings (autocorrect does a lot).
3. Add `opt_in_rules` **a few at a time**, fixing each batch, rather than all at once.
4. Avoid a giant `disabled_rules` list as a shortcut — that's debt that never gets paid. Prefer per-rule thresholds.
5. SwiftLint has no first-class baseline file like detekt; the `excluded:` list + incremental opt-in is the adoption path.

## Common Pitfalls

- **Two formatters fighting** — SwiftLint formatting rules + SwiftFormat both reformatting. Pick one owner for layout.
- **Unpinned linter version** — green CI goes red after a SwiftLint release adds/changes a rule. Pin it.
- **Linting generated code** — noise you can't fix. Always `excluded:`.
- **Blanket `// swiftlint:disable all`** at file top — move the file to `excluded:` instead.
- **Region `disable` without `enable`** — silently disables the rule for the rest of the file.
- **Analyzer rules in the build phase** — slows every build. CI only.
- **No `--strict` in CI** — warnings pile up until the lint output is ignored entirely.
- **Disabling a rule project-wide to fix one file** — suppress at the call site instead.
- **`opt_in_rules` left empty** — you're getting maybe half of SwiftLint's value. The opt-in rules are the good part.

## Patterns to Follow

```yaml
# .swiftlint.yml — a sane starting point for a new project
included: [Sources, Tests]
excluded: [.build, "**/*.generated.swift", Pods]

opt_in_rules:
  - force_unwrapping
  - empty_count
  - first_where
  - explicit_init
  - redundant_nil_coalescing
  - closure_spacing
  - sorted_imports
  - unused_import
  - unused_declaration

analyzer_rules:
  - unused_import
  - unused_declaration

line_length: { warning: 120, error: 200, ignores_urls: true }
identifier_name: { min_length: 2, excluded: [id, x, y, z] }
```

```bash
# CI step — the authoritative gate
swiftlint lint --strict --reporter github-actions-logging

# Local format-on-demand (pick ONE formatter for the project)
swiftformat .            # nicklockwood/SwiftFormat
# or:
swift format -i -r Sources Tests   # Apple's swift-format
```
