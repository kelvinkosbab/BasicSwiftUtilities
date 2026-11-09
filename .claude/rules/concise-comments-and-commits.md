---
description: Keep in-code comments and commit messages terse — verbosity destroys signal and teammates stop reading
globs: "**/*.{swift,h,m,mm,kt,kts}"
paths:
  - "**/*.{swift,h,m,mm,kt,kts}"
must:
  - "Comments explain why, never what; no narration, diff commentary, or commented-out code."
  - "Commit subject: imperative, at most 72 characters, no period."
  - "Add a commit body only when the why isn't obvious; never list files or report test runs."
---

# Concise Comments & Commits

A comment or commit message nobody reads is worse than none — it costs attention and buries the one line that mattered. AI assistants over-produce both. The discipline: **every sentence must earn its place against the reader's attention.**

## In-Code Comments

**Default to no comment.** The bar for writing one: it states something the code *cannot* express — a why, a constraint, a trap. If the code needs a "what" explanation, rename or restructure instead.

Write these:

- **Why, not what** — the constraint behind a non-obvious choice, with an issue/ticket reference when one exists:

  ```swift
  // Sort by id, not name — the renderer assumes stable ordering and names collide (#214).
  let sorted = items.sorted { $0.id < $1.id }
  ```

- **Trap warnings** — "this looks redundant but removing it breaks X."
- Doc comments per [`apple-documentation-strategy.md`](./apple-documentation-strategy.md) / [`android-documentation-strategy.md`](./android-documentation-strategy.md) — a separate concern with its own rules.

Never write these (the AI-assistant signature moves):

- **Narration** — `// Loop through the users`, `// Return the result`.
- **Diff commentary** — `// Added validation`, `// Now correctly handles nil`, `// Updated to use the new API`. That's a message to the *reviewer*; it's noise the moment the change merges. Put it in the PR description.
- **Step numbering** for linear code (`// 1. Fetch  // 2. Parse  // 3. Save`) — extract named functions instead.
- **Section banners** in short files or functions.
- **Commented-out code** — delete it; git remembers.
- **Apologies** (`// hacky but works`) — state the constraint or fix it.

Heuristic: if a routine function has comment lines rivaling code lines, cut until what remains is only what the code can't say.

## Commit Messages

The reader is a teammate scanning `git log --oneline`, or skimming one message for ten seconds. Write for that reader.

- **Subject: imperative, ≤ 72 chars, capitalized, no period.** `Fix crash when scan results are empty` — it should complete "If applied, this commit will …".
- **Body is optional — and usually absent.** A small change whose why is obvious from the diff gets a subject only. Add a body *only* when the why needs context, and keep it to a few lines wrapped at 72.
- **The diff already shows the what.** Never enumerate changed files, restate every hunk as a bullet list, or report process ("ran tests, all green", assertion counts). If the body is an inventory of the diff, delete it.
- **Link, don't inline.** Deep context belongs in the issue/PR — reference it (`#123`) instead of reproducing it.
- **One logical change per commit.** Subjects bloat when commits bundle unrelated work; splitting the commit fixes the message.

```text
# Good — subject only; the diff says the rest
Fix off-by-one in scan-result pagination

# Good — body earns its place: a why the diff can't show
Debounce Bonjour browser restarts

Rapid network flaps caused overlapping browse sessions that NetService
delivers to stale delegates (#87). 300ms holds the previous session.

# Bad — inventory nobody will read
Update networking layer

- Modified NetworkClient.swift to add new retry logic
- Updated NetworkError.swift with two new cases
- Changed SessionManager.swift to use the new client
- Added tests for the retry logic, all 47 passing
- Also fixed a typo in a comment
```

## The Principle

Both rules are the same rule: respect the reader. A terse, accurate line gets read; a thorough essay gets skipped — and information nobody reads was never communicated.
