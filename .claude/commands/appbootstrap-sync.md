---
description: Sync this project with the latest AppBootstrapAI bundle, then audit it against the bundle's rules
argument-hint: "[extra instructions, e.g. 'audit only', 'steering files only', or 'fix the high findings']"
---

Sync this project with the AppBootstrapAI bundle and audit it.

1. **Find the bundle** (the directory that holds `install.sh`), in this order:
   - `$APPBOOTSTRAP_BUNDLE`, if set.
   - `bundle.path` in `.claude/.appbootstrap-manifest.json`, if that directory still has `install.sh`. Run `git -C <path> pull --ff-only` so it's current.
   - Otherwise clone `bundle.repo` from the manifest (default `https://github.com/kelvinkosbab/AppBootstrapAI`) at its latest release tag into a temp directory outside this repo: `TAG=$(git ls-remote --tags --refs --sort=-v:refname <repo> 'v*' | head -1 | sed 's#.*/##')`, then `git clone --depth 1 ${TAG:+--branch "$TAG"} <repo> <dir>`. Use the default branch only if I ask for unreleased changes.
2. **Follow `playbooks/sync-and-audit.md` in that bundle** step by step, with BUNDLE set to the bundle path and TARGET set to this repo's root. Skip its "Find the bundle" step; you just did it.
3. Don't commit, push, or pass `--force`, `--force-conflicts`, or `--prune` unless I ask.

Extra instructions: $ARGUMENTS
