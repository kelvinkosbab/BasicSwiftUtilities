---
description: How to write, scope, and maintain a project's AI steering files (CLAUDE.md, AGENTS.md, GEMINI.md, Copilot / Cursor / Kiro rules, skills) so every agent gets short, true, project-specific guidance
globs: "CLAUDE.md,**/CLAUDE.md,CLAUDE.local.md,AGENTS.md,**/AGENTS.md,GEMINI.md,.cursorrules,.windsurfrules,.github/copilot-instructions.md,.github/instructions/**,.cursor/rules/**,.kiro/steering/**,.claude/rules/**,.claude/skills/**,.claude/agents/**,.claude/commands/**,.claude/settings.json"
paths:
  - "CLAUDE.md"
  - "**/CLAUDE.md"
  - "CLAUDE.local.md"
  - "AGENTS.md"
  - "**/AGENTS.md"
  - "GEMINI.md"
  - ".cursorrules"
  - ".windsurfrules"
  - ".github/copilot-instructions.md"
  - ".github/instructions/**"
  - ".cursor/rules/**"
  - ".kiro/steering/**"
  - ".claude/rules/**"
  - ".claude/skills/**"
  - ".claude/agents/**"
  - ".claude/commands/**"
  - ".claude/settings.json"
must:
  - "Keep always-loaded steering files under about 300 lines; put topic guidance in path-scoped rules and long procedures in skills."
  - "Every path and command in a steering file must exist and work; no placeholders, secrets, or personal preferences."
  - "One source across agents: don't hand-copy the same instructions into CLAUDE.md, AGENTS.md, and other agent files."
  - "Improve in order: fix what's false, remove what's unsafe, cut noise, add what's missing, then restructure."
---

# AI Steering Files

Steering files are the instructions an AI agent reads before it touches the code: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/*.mdc`, `.kiro/steering/*.md`, `.claude/rules/`, skills, subagents, and commands. Always-loaded files are paid for in context on **every** request, and an agent follows a wrong instruction as faithfully as a right one. So the bar is: **short, true, specific to this project, and in one place.**

AppBootstrapAI's `install.sh audit` steering checks (`steering-*` findings) and the steering review in its `playbooks/audit.md` are built on this rule.

## What Earns a Place

Write down what an agent **can't infer from the code** and would otherwise get wrong:

- **Commands that work.** Build, test (all and one), lint, format, run — copy-pasteable, for this repo. `swift test --package-path MyAppPackages`, `./gradlew :feature:tasks:impl:testDebugUnitTest`.
- **The map.** Module/directory table and dependency direction, where new code goes, what's generated and must not be edited.
- **Project decisions that differ from the defaults.** "We use XCTest, not Swift Testing, until the CI image moves" beats a generic testing essay. Link the ADR.
- **Gotchas.** The flaky simulator, the env var a test needs, the file that must change in lockstep with another.
- **Boundaries.** What needs a human: migrations, releases, pushing, anything irreversible.

Leave out:

- **Generic advice** ("write clean code", "follow best practices", "be careful with concurrency"). It changes nothing an agent does. Replace it with the concrete rule or delete it.
- **What a linter or compiler already enforces.** Point at the config (`.swiftlint.yml`, `.editorconfig`, `detekt.yml`) instead of restating it.
- **What a bundled rule already says.** If this bundle is installed, don't paste its rules into `CLAUDE.md` too. Record only where the project *deviates*, and say so explicitly ("Exception to `apple-swiftui-mvvm.md`: …").
- **Secrets, tokens, internal hostnames.** Steering files are committed and sent to model providers. Reference the secret's name and where it lives.
- **Personal preferences.** They go in `CLAUDE.local.md` / user-level config, which stays out of git.
- **History.** "We used to…" belongs in the CHANGELOG or an ADR.

## Write Instructions, Not Descriptions

- **Prescriptive and checkable.** "ViewModels are `@MainActor @Observable final class`" is followable and reviewable; "think about isolation" is not.
- **Say why in one clause** when the rule looks arbitrary, so the agent can handle the edge case: "No `Date()` in view models — tests inject a clock."
- **One rule per bullet.** Lists scan; paragraphs get skimmed.
- **Resolve contradictions.** Two files that disagree (CLAUDE.md says Swift Testing, `.cursor/rules/testing.mdc` says XCTest) make agents pick at random. One answer, one place.

## Size and Scope

- **Keep each always-loaded file under ~300 lines** (roughly 25 KB). Past that, split by topic into scoped rule files and link them.
- **Scope by path.** Guidance that only matters for Kotlin goes in a rule that fires on `**/*.kt`, not in the root file. Each agent has its own key:

  | Agent | File | Scoping |
  |---|---|---|
  | Claude Code | `.claude/rules/*.md` | `paths:` YAML list (`globs:` is not read); no `paths:` = always loaded |
  | Claude Code | `.claude/skills/<name>/SKILL.md` | `name:` + `description:` (the description decides when it loads) |
  | Claude Code | nested `CLAUDE.md` | loaded when working in that directory |
  | Cursor | `.cursor/rules/*.mdc` | `description`, `globs`, `alwaysApply` |
  | GitHub Copilot | `.github/instructions/*.instructions.md` | `applyTo:` |
  | Kiro | `.kiro/steering/*.md` | `inclusion: always \| fileMatch \| manual` + `fileMatchPattern` |

- **Nest per area in a monorepo**: `apple/CLAUDE.md`, `android/CLAUDE.md` (see [`cross-platform-development.md`](./cross-platform-development.md)). The root file holds only what every task needs.
- **Long procedures become skills or commands**, loaded on demand, not paragraphs in the root file.

## One Source Across Agents

Teams run more than one agent. Copies drift: the Cursor rules get the new test command, `CLAUDE.md` doesn't.

- **Pick one source** and derive the rest. Common shapes:
  - `AGENTS.md` as the source; `CLAUDE.md` imports it (`@AGENTS.md`) and adds only Claude-specific notes; point Gemini CLI's `contextFileName` at it.
  - `.claude/rules/` as the source, fanned out by `install.sh --agents …` or a sync tool ([`ruler`](https://github.com/intellectronica/ruler), [`block/ai-rules`](https://github.com/block/ai-rules)).
- **Generated files say so** in their first line and are never hand-edited.
- **Retire legacy formats**: `.cursorrules` → `.cursor/rules/*.mdc`.

## Keep It True

A stale instruction is worse than none: the agent runs the dead command or edits the moved file.

- **Every path and command in a steering file must exist.** Update steering in the same change that renames a module, script, or Gradle task.
- **Template placeholders** (`<PROJECT_NAME>`, `<PLACEHOLDER>`) get filled or deleted on day one.
- **Review steering at each release** alongside the README; run `install.sh audit` to catch stale paths and commands.
- **Dates and versions** ("Swift 6.4", "targetSdk 36") get updated or removed when the toolchain moves.

## Permissions and Safety

- **Committed agent settings grant the minimum.** No blanket `Bash(*)` / bare `Bash` allow, no `bypassPermissions` default in a shared `.claude/settings.json`. Per-developer loosening goes in the git-ignored `settings.local.json`.
- **Git-ignore local files**: `CLAUDE.local.md`, `.claude/settings.local.json`.
- **Treat third-party steering as code.** A rule file or skill copied from the internet runs with the agent's permissions; read it before committing it.

## Improving an Existing Set

Work in this order, one small change at a time, and let the developer review each:

1. **Fix what's false**: stale paths and commands, contradictions, unfilled placeholders.
2. **Remove what's unsafe**: secrets, over-broad permissions.
3. **Cut what's noise**: generic advice, restated lint rules, restated bundle rules, history.
4. **Add what's missing**: working build/test commands, the module map, the real gotchas.
5. **Restructure**: split oversized files into scoped rules, collapse per-agent copies to one source.

## Common Pitfalls

- **A 1,000-line `CLAUDE.md`** that every request pays for and nobody maintains.
- **The same rules pasted into four agent files**, now four slightly different versions.
- **Commands that stopped working** after a module or task rename.
- **"Use best practices"** with no practice named.
- **Unscoped rule files** that load on every request when they apply to one directory.
- **Skills without a `description`**, so they never trigger.
- **API keys in a steering file**, now sent to every model provider the team uses.
- **`.cursorrules`** left behind after moving to `.cursor/rules/`.
