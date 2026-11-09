---
description: Audit one area of this project (concurrency, architecture, accessibility, …) against only the AppBootstrapAI rules and skills for it
argument-hint: "<topic> [extra instructions], e.g. 'concurrency' or 'architecture only the Networking module'"
---

Audit one area of this project with the AppBootstrapAI bundle, loading only that area's guidance.

1. **Find the bundle** (the directory that holds `install.sh`), in this order:
   - `$APPBOOTSTRAP_BUNDLE`, if set.
   - `bundle.path` in `.claude/.appbootstrap-manifest.json`, if that directory still has `install.sh`.
   - Otherwise clone `bundle.repo` from the manifest (default `https://github.com/kelvinkosbab/AppBootstrapAI`) at its latest release tag into a temp directory outside this repo: `TAG=$(git ls-remote --tags --refs --sort=-v:refname <repo> 'v*' | head -1 | sed 's#.*/##')`, then `git clone --depth 1 ${TAG:+--branch "$TAG"} <repo> <dir>`. Use the default branch only if I ask for unreleased changes.
2. **Pick the topic** from the first word of the extra instructions. With no topic, list the topics in `$BUNDLE/lib/topics.json` (name and description) and stop.
3. **Run** `"$BUNDLE/install.sh" audit . --topic <topic> --json`, then follow steps 3, 4 and 6 of `playbooks/audit.md` in the bundle. Read only the files in `topic.rule_paths` and `topic.skill_paths`, and only the skill references the review needs. Skip the steering review.
4. This is read-only: report in chat, and don't edit, commit, or push unless I ask.

Extra instructions: $ARGUMENTS
